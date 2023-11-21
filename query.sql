create database proj;
use proj;
-- 
drop table company_profile;
drop table company_price;
drop table fundamental_report;
drop table technical_signals;
drop table user_profile;
drop table transaction_history;

show tables;
desc company_profile;

create table company_profile
(
symbol varchar(6),
company_name varchar(100) NOT NULL,
sector varchar(20) NOT NULL,
market_cap bigint NOT NULL,
paidup_capital bigint NOT NULL,
primary key(symbol)
);

create table company_price
(
symbol varchar(6),
LTP float NOT NULL,
PC float NOT NULL,
primary key(symbol),
foreign key(symbol) references company_profile(symbol) on delete cascade
);

create table fundamental_report
(
symbol varchar(6),
report_as_of varchar(10),
EPS float NOT NULL,
ROE float NOT NULL,
book_value float NOT NULL,
primary key (symbol, report_as_of),
foreign key (symbol) references company_profile(symbol) on delete cascade
);

create table technical_signals
(
symbol varchar(6),
LTP float,
RSI float NOT NULL,
volume float NOT NULL,
ADX float NOT NULL,
MACD varchar(4) NOT NULL,
primary key (symbol),
foreign key (symbol) references company_profile(symbol) on delete cascade
);


create table user_profile
(
username varchar(30),
email varchar(60) UNIQUE NOT NULL,
phone bigint UNIQUE NOT NULL,
user_password varchar(224),
primary key(username)
);
select username from user_profile;


create table transaction_history
(
transaction_id int auto_increment,
username varchar(30) NOT NULL,
symbol varchar(6) NOT NULL,
transaction_date datetime NOT NULL,
quantity int NOT NULL,
rate float NOT NULL,
primary key(transaction_id),
foreign key(symbol) references company_profile(symbol) on delete cascade,
foreign key(username) references user_profile(username) on delete cascade
);


-- Data entry
insert into user_profile values
('rewan', 'uni.rayone@gmail.com', 9800000001, 'rewan123'),
('mahesh', 'uni@gmail.com', 9800000002, 'arewan123'),
('suman', 'uni1.rayone@gmail.com', 9800000003, 'rewan12345'),
('madhu', 'uni2.rayone@gmail.com', 9800000004,'arewan123'),
('sobit', 'uni3.rayone@gmail.com', 9800000005,'brewan123'),
('ray', 'uni4.rayone@gmail.com', 9800000006,'crewan123'),
('rayone', 'uni5.rayone@gmail.com', 9800000007,'drewan123'),
('ravi', 'uni6.rayone@gmail.com', 9800000008,'erewan123'),
('michael', 'uni7.rayone@gmail.com', 9800000009,'frewan123'),
('hari', 'uni8.rayone@gmail.com', 9811111111,'arewan123'),
('madan', 'uni10.rayone@gmail.com', 9800000010,'rfewan123'),
('sandeep', 'uni11.rayone@gmail.com', 9800000011,'frewan123'),
('surya', 'tha0751@gmail.com', 9860000014,'arewan123'),
('vai', 'tha0752@gmail.com', 9860000013,'wrewan123'),
('gtm', 'tha075@gmail.com', 9860000012,'erewan123');

insert into company_profile values
('KBL', 'Kumari Bank', 'Bank', 1000000000, 21212121221),
('NIL', 'Nepal Insurance Limited', 'Life Insurance', 123232332, 131321321),
('LEC', 'Libery Energy', 'Hydropower', 63233232, 61321321),
('ELEX', 'Nepal Electronics Bank', 'Bank', 32323233232, 323321321321),
('NEPP', 'Nepal Power', 'Hydropower', 102323233232, 10323321321321),
('LSL', 'Life Saver Limited', 'Life Insurance', 23233232, 21321321),
('NBL', 'Nepal Bank Limited', 'Bank', 532323233232, 5323321321321),
('HEX', 'Hotel Electronics', 'Hotels', 82323233232, 823321321321),
('HIH', 'Hotel Itahari', 'Hotels', 12323233232, 123321321321),
('BIH', 'Bank of Itahari', 'Bank', 62323233232, 623321321321);


insert into company_price (symbol, LTP, PC) values
('KBL', 500, 470),
('NIL', 5800, 6000),
('LEC', 400, 410),
('ELEX', 1010, 1000),
('NEPP', 500, 480),
('LSL', 1000, 1040),
('NBL', 600, 580.5),
('HEX', 1222.3, 1220),
('HIH', 1500.5, 1499.4),
('BIH', 788, 777);

insert into fundamental_report(symbol, report_as_of, EPS, ROE, book_value) values
('KBL', '77/78_q3', 20.5, 11.97, 120),
('KBL', '77/78_q2', 19.5, 10, 110),  
('NIL', '77/78_q3', 205, 50, 300),
('NIL', '77/78_q2', 211, 55, 310),
('LEC', '77/78_q3', 8, 4, 90),
('LEC', '77/78_q2', 7.5, 3.5, 88),
('ELEX', '77/78_q3', 34, 15, 180),
('ELEX', '77/78_q2', 31, 13, 178),
('NEPP', '77/78_q3', 21, 12, 119),
('NEPP', '77/78_q2', 20, 11, 118),
('LSL', '77/78_q3', 30, 12, 170),
('LSL', '77/78_q2', 35.4, 13, 180.5),
('NBL', '77/78_q3', 22, 13, 120),
('NBL', '77/78_q2', 21, 12, 117),
('HEX', '77/78_q3', 50, 15, 200),
('HEX', '77/78_q2', 48, 14, 199),
('HIH', '77/78_q3', 60, 20, 220),
('HIH', '77/78_q2', 55, 18, 200),
('BIH', '77/78_q3', 36, 20, 220),
('BIH', '77/78_q2', 35, 21, 200);

insert into technical_signals(symbol, RSI, volume, ADX, MACD) values 
('KBL', 65.1, 451000, 33.3, 'bull'), 
('NIL', 50.5, 100000, 40, 'bull'), 
('LEC', 20, 12344, 15, 'bear'),
('ELEX', 70, 1200000, 30, 'bull'),
('NEPP', 45, 212000, 16.5, 'bull'),
('LSL', 53.4, 15312, 25.29, 'bull'),
('NBL', 66.41, 406121, 34.66, 'bull'),
('HEX', 40.2, 34000, 40, 'side'),
('HIH', 35, 120000, 30, 'side'),
('BIH', 75, 335000, 44, 'bull');


-- Updating LTP values in technical_signals
-- UPDATE technical_signals A
-- INNER JOIN company_price B ON A.symbol = B.symbol
-- SET A.LTP = B.LTP
-- WHERE A.symbol = B.symbol;

insert into transaction_history(username, symbol, transaction_date, quantity, rate) values
('rewan', 'HEX', '2021-07-01', 100, 1200),
('rewan', 'HIH', '2021-07-02', 55, 1480),
('rewan', 'HIH', '2021-07-06', -20, 1500),
('suman', 'LEC', '2021-07-10', 10, 420),
('suman', 'LEC', '2021-07-15', 10, 410),
('rewan', 'BIH', '2021-07-20', 120, 785.5),
('rewan', 'LSL', '2021-07-20', 55, 1001);

-- Holdings
Create view holdings_view as
select username, symbol, sum(quantity) as quantity  from transaction_history
group by username, symbol;

-- Holdings with LTP and current value for user rewan
select A.symbol, A.quantity, B.LTP, round(A.quantity*B.LTP, 2) as current_value from holdings_view A
inner join company_price B
on A.symbol = B.symbol
where username = 'rewan';

-- Fundamental report 
Create view fundamental_averaged as
SELECT F.symbol, LTP, round(avg(EPS), 2) as EPS, round(avg(ROE), 2) as ROE, 
round(avg(book_value), 2) AS book_value, round(avg(LTP/EPS), 2) AS pe_ratio 
FROM fundamental_report F
INNER JOIN company_price C
on F.symbol = C.symbol
group by(Symbol);

select * from  fundamental_averaged;

-- Fundamental report of certain company without averaging
select F.symbol, report_as_of, LTP, eps, roe, book_value, round(LTP/eps, 2) as pe_ratio
from fundamental_report F
inner join company_price C
on F.symbol = C.symbol
where F.symbol = 'BIH';

-- Technical report
select A.symbol, sector, LTP, volume, RSI, ADX, MACD from technical_signals A 
left join company_profile B
on A.symbol = B.symbol
order by (A.symbol);

-- Company profile
select * from company_profile
order by(symbol);

-- Company price
SELECT symbol, LTP, PC, round((LTP-PC), 2) as CH, round(((LTP-PC)/PC)*100, 2) AS CH_percent FROM company_price
order by symbol;

-- Dividend
select * from dividend_history;

-- Portfolio system 

-- Certain user portfolio
select *
from holdings_view A
left outer join company_price B on A.symbol = B.symbol
left outer join fundamental_averaged F on A.symbol = F.symbol
left outer join technical_signals T on A.symbol = T.symbol
where username = 'rewan'
order by (A.symbol);	

-- Fundamentally strong
select A.symbol from holdings_view A 
left outer join fundamental_report F on A.symbol = F.symbol
where username = 'rewan'
group by(symbol);

-- Best companies to invest
select * from company_price
natural join fundamental_averaged
natural join technical_signals
natural join company_profile 
where 
EPS>25 and roe>13 and 
book_value > 100 and
rsi>50 and adx >23 and
pe_ratio < 35 and
macd = 'bull'
order by symbol;

-- EPS more than 30
select * from fundamental_averaged
where eps > 30;

-- PE Ratio less than 30
select * from fundamental_averaged
where pe_ratio <30;

-- Technically
select * from technical_signals
where ADX > 23 and rsi>50 and rsi<70 and MACD = 'bull';

-- Total profit or loss
select * from transaction_history;
select * from holdings_view;

select username, A.symbol, sum(quantity) as quantity, sum(total) as total, round(sum(total)/sum(quantity), 2) as updated_rate,
B.LTP, round((B.LTP * sum(quantity) - sum(total)), 2) as profit_loss  
from transaction_history A left outer join company_price B
on A.symbol = B.symbol
group by A.username, A.symbol;


-- For pie chart (sector with total values)
select C.sector, sum(A.quantity*B.LTP) as current_value 
from holdings_view A
inner join company_price B
on A.symbol = B.symbol
inner join company_profile C
on A.symbol = C.symbol
where username = 'rewan'
group by C.sector;


-- Profit loss in portfolio

-- Function to find total amount (amount + broker commission + sebon fee + DP charge) excluding capital gain tax
DELIMITER $$
CREATE FUNCTION getTotal(
	total float
) 
RETURNS float
DETERMINISTIC
BEGIN
	DECLARE total_converted float;
    DECLARE comm float;
    DECLARE ptotal float;
    
    -- If sell, make the total positive to calculate commission later
    IF total<0 THEN
		SET ptotal = -total;
	ELSE 
		SET ptotal = total;
	END IF;
	
    -- Commission is same for both buy and sell
    IF ptotal > 500000 THEN
		SET comm = (0.34/100)*ptotal;
	ELSEIF ptotal > 50000 THEN
		SET comm = (0.37/100)*ptotal;
	ELSEIF ptotal > 2500 THEN
		SET comm = (0.4/100)*ptotal;
	ELSEIF ptotal > 100 THEN
		SET comm =  10;
	END IF;
    
    -- If sell conditions
	IF total < 0 THEN
		set total = -total;
		set total_converted = total - (comm + total*(0.015/100) + 25);
        RETURN total_converted;
    END IF;
    
	SET total_converted = total + comm + 25 + (0.015/100)*total;
	RETURN (total_converted);
END$$
DELIMITER ;


drop function getTotal;

-- Function to find profit loss with capital gain tax deducted
DELIMITER $$
CREATE FUNCTION capGain(
	total float,
    trans_date date
) 
RETURNS float
DETERMINISTIC
BEGIN
    IF total<0 THEN
		RETURN total;
	ELSEIF datediff(Now(), trans_date)<365 THEN
		SET total = total - 0.075*total;
	ELSE 
		SET total = total - 0.05*total;
	END IF;
	RETURN total;
END$$
DELIMITER ;

drop function capGain;
    

DELIMITER $$

CREATE PROCEDURE portfo(IN in_username VARCHAR(30))
BEGIN
    SELECT
        symbol,
        SUM(quantity) AS quantity,
        LTP,
        MAX(rate) AS rate,
        ROUND((getTotal(-SUM(quantity) * LTP)), 2) AS current_value,
        capGain(ROUND((getTotal(-SUM(quantity) * LTP)) - (getTotal(SUM(quantity) * MAX(rate))), 2), MAX(transaction_date)) AS profit_loss
    FROM
        transaction_history T
    NATURAL JOIN
        company_price C
    WHERE
        T.username = in_username
    GROUP BY
        symbol;
END $$

DELIMITER ;

drop procedure portfolio;
call portfo('rewan');

DELIMITER $$

CREATE TRIGGER before_insert_update_transaction_history
BEFORE INSERT ON transaction_history
FOR EACH ROW
BEGIN
    -- Check if quantity exceeds 1000
    IF NEW.quantity > 1000 THEN
        -- Set quantity to the limit of 1000
        SET NEW.quantity = 1000;
    END IF;
END $$

DELIMITER ;

DROP TRIGGER IF EXISTS before_insert_transaction_history;

CREATE USER 'admin'@'localhost' IDENTIFIED BY 'your_password';

GRANT SELECT, UPDATE, ALTER ON proj.transaction_history TO 'admin'@'localhost';

GRANT SELECT, INSERT, UPDATE, ALTER, INDEX, DROP ON proj.user_profile TO 'admin'@'localhost';

GRANT SELECT, INSERT, UPDATE, ALTER, INDEX, DROP ON proj.company_profile TO 'admin'@'localhost';

GRANT SELECT, INSERT, UPDATE, ALTER ON proj.fundamental_report TO 'admin'@'localhost';

FLUSH PRIVILEGES;