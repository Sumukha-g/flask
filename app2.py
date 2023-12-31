from flask import Flask, render_template,request,session,redirect,url_for
import mysql.connector
import hashlib
app = Flask(__name__)
app.secret_key="123"
mysql_config = {
    'host': '127.0.0.1',
    'user': 'root',
    'password': 'Sumukha123',
    'database': 'projec'
}

def get_mysql_connection():
    return mysql.connector.connect(**mysql_config)

def is_admincheck():
    return 'user' in session and session['user'] == 'admin'
@app.route('/')
def index():
    session.permanent = True
    return render_template('index.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    is_admin_param = request.args.get('is_admin', 0)  # Default to 0 if not present

    if request.method == 'POST':
        
        username = request.form.get("username", None)
        user_password = request.form.get("password", None)

        connection = get_mysql_connection()
        cursor = connection.cursor()

        # Query the database for the user's information
        query = "SELECT username, user_password FROM user_profile"
        cursor.execute(query)
        user_data = cursor.fetchall()

        if (username, user_password) in user_data:
            session["user"] = username
            # Assuming you have a way to determine if the user is an admin
            is_admin =is_admincheck()
            return redirect(url_for("portfolio", is_admin=is_admin))

        else:
            # User does not exist or incorrect password, show an error message
            error_message = "Incorrect username or password. Please try again."
            return render_template("login.html", error_message=error_message, is_admin=is_admin_param)

    return render_template("login.html", is_admin=is_admin_param)



@app.route('/signup', methods=['GET', 'POST'])
def signup():
    if request.method == 'POST':
        # Get form data
        username = request.form.get('username')
        email = request.form.get('email')
        phone = request.form.get('phone')
        password = request.form.get('password')
        # Insert data into MySQL table
        try:
            connection = get_mysql_connection()
            cursor = connection.cursor()

            insert_query = "INSERT INTO user_profile (username, email, phone,user_password) VALUES (%s, %s, %s, %s)"
            data = (username, email, phone, password)

            cursor.execute(insert_query, data)
            connection.commit()

            return redirect(url_for('index'))

        except mysql.connector.Error as err:
            return f"Error: {err}"

        finally:
            cursor.close()
            connection.close()

    return render_template('signup.html',is_admin=is_admincheck())


@app.route('/add_element', methods=['GET', 'POST'])
def add_element():
    if not is_admincheck():
        return redirect(url_for('index'))

    if request.method == 'POST':
        symbol = request.form['symbol']
        LTP = float(request.form['LTP'])
        PC = float(request.form['PC'])
        company_name = request.form['company_name']
        sector = request.form['sector']
        market_cap = int(request.form['market_cap'])
        paidup_capital = int(request.form['paidup_capital'])
        connection = get_mysql_connection()
        cursor = connection.cursor()
        cursor.execute('INSERT INTO company_profile (symbol,company_name,sector,market_cap,paidup_capital) VALUES (%s,%s,%s,%s,%s)',(symbol,company_name,sector,market_cap,paidup_capital))
        cursor.execute('INSERT INTO company_price (symbol, LTP, PC) VALUES (%s, %s, %s)', (symbol, LTP, PC))
        connection.commit()
        return redirect(url_for('index'))

    return render_template('add_element.html')
@app.route('/delete_element', methods=['GET', 'POST'])
def delete_element():
    if request.method == 'GET':
        connection = get_mysql_connection()
        cursor = connection.cursor()
        cursor.execute("SELECT symbol, company_name FROM company_profile")
        companies = cursor.fetchall()
        connection.close()
        return render_template('delete_element.html', companies=companies)

    elif request.method == 'POST':
        company_symbol_to_delete = request.form['company_select']
        connection = get_mysql_connection()
        cursor = connection.cursor()

        # Implement company deletion logic here
        cursor.execute("DELETE FROM company_profile WHERE symbol = %s", (company_symbol_to_delete,))
        # You may also want to delete related records in other tables
        
        connection.commit()
        connection.close()

        return redirect(url_for('portfolio')) 

@app.route('/portfolio.html')
def portfolio():

    # Check if we have logged in users
    if "user" not in session:
        return render_template('alert.html')
    connection = get_mysql_connection()
    cursor = connection.cursor()
    # Query for holdings
    user = [session['user']]
    user2 = (session['user'],)
    cursor.execute('CALL portfo(%s)', user2)
    holdings = cursor.fetchall()
    cursor.close()
    connection = get_mysql_connection()
    cursor = connection.cursor()


    # Query for stock suggestion
    query_suggestions = """
SELECT CP.symbol,FA.EPS,FA.ROE,FA.book_value,TS.rsi,TS.adx,FA.pe_ratio,TS.macd
FROM company_price CP
JOIN
    fundamental_averaged FA ON CP.symbol = FA.symbol
JOIN
    technical_signals TS ON CP.symbol = TS.symbol
JOIN
    company_profile CPY ON CP.symbol = CPY.symbol
WHERE
    FA.EPS > 25 AND FA.ROE > 13 AND FA.book_value > 100 AND
    TS.rsi > 50 AND TS.adx > 23 AND
    FA.pe_ratio < 35 AND TS.macd = 'bull'
ORDER BY CP.symbol"""
    cursor.execute(query_suggestions)
    suggestions = cursor.fetchall()
    # Query on EPS
    query_eps = '''select symbol, ltp, eps from fundamental_averaged
where eps > 30
order by eps;'''
    cursor.execute(query_eps)
    eps = cursor.fetchall()

    # Query on PE Ratio
    query_pe = '''select symbol, ltp, pe_ratio from fundamental_averaged
where pe_ratio <30;'''
    cursor.execute(query_pe)
    pe = cursor.fetchall()

    # Query on technical signals
    query_technical = '''select * from technical_signals
where ADX > 23 and rsi>50 and rsi<70 and MACD = 'bull';'''
    cursor.execute(query_technical)
    technical = cursor.fetchall()

    # Query for pie chart
    query_sectors = '''select C.sector, sum(A.quantity*B.LTP) as current_value 
from holdings_view A
inner join company_price B
on A.symbol = B.symbol
inner join company_profile C
on A.symbol = C.symbol
where username = %s
group by C.sector;
'''
    cursor.execute(query_sectors, user)
    sectors_total = cursor.fetchall()
    # Convert list to json type having percentage and label keys
    piechart_dict = toPercentage(sectors_total)
    piechart_dict[0]['type'] = 'pie'
    piechart_dict[0]['hole'] = 0.4
    if "user" not in session:
        return render_template('alert.html')
    if is_admincheck():
        return render_template('portfolio2.html', is_admin=1, holdings=holdings, user=user[0], suggestions=suggestions, eps=eps, pe=pe, technical=technical, piechart=piechart_dict)
    return render_template('portfolio2.html', holdings=holdings, user=user[0], suggestions=suggestions, eps=eps, pe=pe, technical=technical, piechart=piechart_dict)


def toPercentage(sectors_total):
    json_format = {}
    total = 0

    for row in sectors_total:
        total += row[1]

    json_format['values'] = [round((row[1]/total)*100, 2)
                             for row in sectors_total]
    json_format['labels'] = [row[0] for row in sectors_total]
    return [json_format]
    
        
@app.route('/add_transaction.html', methods=['GET', 'POST'])
def add_transaction():
    if "user" not in session:
        return render_template('alert.html')
    connection = get_mysql_connection()
    cursor = connection.cursor()
    # Query for all companies (for drop down menu)
    query_companies = '''select symbol from company_profile'''
    cursor.execute(query_companies)
    companies = cursor.fetchall()

    if request.method == 'POST':
        transaction_details = request.form
        symbol = transaction_details['symbol']
        date = transaction_details['transaction_date']
        transaction_type = transaction_details['transaction_type']
        print(type(date),symbol)
        quantity = float(transaction_details['quantity'])
        rate = float(transaction_details['rate'])
        if transaction_type == 'Sell':
            quantity = -quantity
        query = '''insert into transaction_history(username, symbol, transaction_date, quantity, rate) values
(%s, %s, %s, %s, %s)'''
        values = [session['user'], symbol, date, quantity, rate]
        cursor.execute(query, values)
        connection.commit()

    return render_template('add_transaction.html', companies=companies)
@app.route('/stockprice.html')
def stockprice(company='all'):
    if "user" not in session:
        return render_template('alert.html')
    connection = get_mysql_connection()
    cursor = connection.cursor()
    if company == 'all':
        query = '''SELECT symbol, LTP, PC, round((LTP-PC), 2) as CH, round(((LTP-PC)/PC)*100, 2) AS CH_percent FROM company_price
order by symbol;
'''
        cursor.execute(query)
    else:
        company = [company]
        query = '''SELECT symbol, LTP, PC, round((LTP-PC), 2) as CH, round(((LTP-PC)/PC)*100, 2) AS CH_percent FROM company_price
        where symbol = %s;
'''
        cursor.execute(query, company)
    rv = cursor.fetchall()
    return render_template('stockprice.html', values=rv)


@app.route('/fundamental.html', methods=['GET'])
def fundamental_report(company='all'):
    if "user" not in session:
        return render_template('alert.html')
    connection = get_mysql_connection()
    cursor = connection.cursor()
    if company == 'all':
        query = '''select * from  fundamental_averaged;'''
        cursor.execute(query)
    else:
        company = [company]
        query = '''select F.symbol, report_as_of, LTP, eps, roe, book_value, round(LTP/eps, 2) as pe_ratio
from fundamental_report F
inner join company_price C
on F.symbol = C.symbol
where F.symbol = %s'''
        cursor.execute(query, company)
    rv = cursor.fetchall()
    return render_template('fundamental.html', values=rv)

@app.route('/technical.html')
def technical_analysis(company='all'):
    if "user" not in session:
        return render_template('alert.html')
    connection = get_mysql_connection()
    cursor = connection.cursor()
    if company == 'all':
        query = '''select A.symbol, sector, LTP, volume, RSI, ADX, MACD from technical_signals A 
left join company_profile B
on A.symbol = B.symbol
order by (A.symbol)'''
        cursor.execute(query)
    else:
        company = [company]
        query = '''SELECT * FROM technical_signals where company = %s'''
        cursor.execute(query, company)
    rv = cursor.fetchall()
    return render_template('technical.html', values=rv)


@app.route('/companyprofile.html')
def company_profile(company='all'):
    if "user" not in session:
        return render_template('alert.html')
    connection = get_mysql_connection()
    cursor = connection.cursor()
    if company == 'all':
        query = '''select * from company_profile
order by(symbol);
'''
        cursor.execute(query)
    else:
        company = [company]
        query = '''select * from company_profile where company = %s'''
        cursor.execute(query, company)
    rv = cursor.fetchall()
    return render_template('companyprofile.html', values=rv)


@app.route('/holdings.html')
def holdings():
    if "user" not in session:
        return render_template('alert.html')
    
    query_holdings = '''select A.symbol, A.quantity, B.LTP, round(A.quantity*B.LTP, 2) as current_value from holdings_view A
inner join company_price B
on A.symbol = B.symbol
where username = %s
'''
    connection = get_mysql_connection()
    cursor = connection.cursor()
    cursor.execute(query_holdings, [session['user']])
    holdings = cursor.fetchall()

    return render_template('holdings.html', user=session['user'], holdings=holdings)

@app.route('/remove_user', methods=['GET','POST'])
def remove_user_form():
    if request.method == 'GET':
        connection = get_mysql_connection()
        cursor = connection.cursor()
        cursor.execute("SELECT username FROM user_profile")
        users = cursor.fetchall()
        connection.close()
        return render_template('remove_user.html', users=users)
    if request.method == 'POST':
        user_id_to_delete =request.form['user_select']
        connection = get_mysql_connection()
        cursor = connection.cursor()
        
        # Implement user deletion logic here
        cursor.execute("DELETE FROM user_profile WHERE username = %s", (user_id_to_delete,))
        
        connection.commit()
        connection.close()

        return redirect(url_for('portfolio'))
@app.route('/adminp', methods=['GET'])
def adminp():
    if "user" not in session:
        return render_template('alert.html')
    return render_template('adminp.html')
@app.route('/logout', methods=['GET', 'POST'])
def logout():
    session.pop('user', None)
    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(debug=True)