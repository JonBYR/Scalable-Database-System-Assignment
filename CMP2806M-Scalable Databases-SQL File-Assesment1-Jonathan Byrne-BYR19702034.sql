-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 23, 2022 at 06:47 PM
-- Server version: 10.4.21-MariaDB
-- PHP Version: 8.0.10

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

CREATE DATABASE `BankDatabase`;
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `bankdatabase`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `getGreaterBalances` (IN `balanceThreshold` FLOAT)  BEGIN #begins procedure
SELECT customers.CustomerID, customers.FirstName, customers.LastName, SUM(transactions.Amount) AS Current_Balance FROM transactions, customers, has, bankaccounts
#procedure displays the customer's first and last name and their current balance
WHERE customers.CustomerID = has.CustomerID AND has.AccountID = bankaccounts.AccountID AND bankaccounts.AccountID = transactions.AccountID
GROUP BY customers.CustomerID, bankaccounts.AccountID HAVING SUM(transactions.Amount) > balanceThreshold;
#Customer only displayed if their transaction sum is greater than the balanceThreshold given into the procedure
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `NewTransaction` (`id` INT, `message` VARCHAR(255), `money` FLOAT, `possibleLoan` BOOLEAN, `payDate` DATE, `aId` INT)  BEGIN
INSERT INTO transactions Values(id, message, money, possibleLoan, payDate, aId);
UPDATE bankaccounts
SET Balance = Balance + money
WHERE AccountID = aId;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `showResult` (IN `result` FLOAT(20,2))  BEGIN
SELECT result AS Total_Outstandings; #as the out parameter has been given data in the outer procedure we can then 
#select it in the inner procedure and display it as Total_Outstandings
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `totalOutstandings` (OUT `result` FLOAT(20,2))  BEGIN
WITH RemainingLoans AS(SELECT SUM(TIMESTAMPDIFF(MONTH, l.NextPayment, l.FullPaymentConfirmed) * l.MonthlyPaymentRate) AS OutstandingLoans FROM loans AS l), 
CurrentBalances AS(SELECT SUM(t.amount) AS allBalances FROM transactions AS t) #with used from 4.4
SELECT allBalances - OutstandingLoans INTO result FROM RemainingLoans, CurrentBalances; 
#the resulting value that comes from the temporary tables is the passed into the out parameter.
CALL showResult(result); #the out parameter is used as an in parameter on the inner query
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `addresses`
--

CREATE TABLE `addresses` (
  `AddressID` int(7) NOT NULL,
  `HouseNumber` int(3) DEFAULT NULL,
  `City` varchar(255) DEFAULT NULL,
  `Street` varchar(255) DEFAULT NULL,
  `Postcode` varchar(255) DEFAULT NULL,
  `LandlineNumber` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `addresses`
--

INSERT INTO `addresses` (`AddressID`, `HouseNumber`, `City`, `Street`, `Postcode`, `LandlineNumber`) VALUES
(1, 2, 'Lincoln', 'Ruston Way', 'LN6 12R', '07812459710'),
(2, 1, 'Grimsby', 'Fishy Alley', 'GR5 6TS', '07014279126'),
(3, 7, 'London', 'Oxford Street', 'LO2 0QW', '07910239224'),
(4, 8, 'Gillingham', 'Spider Avenue', 'GI0 T67', '07345789123'),
(5, 12, 'Glasgow', 'Celtic Street', 'GL4 7TY', '07171892340'),
(6, 56, 'London', 'Fleet Street', 'LO4 1YU', '07699123091'),
(7, 124, 'Lincoln', 'Sincil Bank', 'LN5 8LD', '07812356715');

-- --------------------------------------------------------

--
-- Table structure for table `bankaccounts`
--

CREATE TABLE `bankaccounts` (
  `AccountID` int(7) NOT NULL,
  `Name` varchar(255) DEFAULT NULL,
  `CreationDate` date DEFAULT NULL,
  `SortCode` int(6) DEFAULT NULL,
  `Balance` float(8,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `bankaccounts`
--

INSERT INTO `bankaccounts` (`AccountID`, `Name`, `CreationDate`, `SortCode`, `Balance`) VALUES
(1, 'Student', '2021-07-19', 100123, -240.00),
(2, 'Current', '2021-10-31', 941799, 6245.50),
(3, 'Business', '2020-11-16', 192341, -340.00),
(4, 'Joint', '2021-05-05', 107360, 2860.00),
(5, 'Business', '2021-09-12', 459219, 2445.00),
(6, 'Current', '2021-11-19', 710501, 5560.00),
(7, 'Graduate', '2021-08-06', 189293, 680.00),
(8, 'Student', '2021-07-29', 109289, 1087.73),
(9, 'Business', '2020-07-09', 108497, 2810.00),
(10, 'Current', '2021-04-12', 891091, 243.30),
(11, 'Savings', '2021-04-12', 891123, 1310.00),
(12, 'Savings', '2021-10-31', 947321, 1060.00),
(13, 'Savings', '2021-11-19', 719124, 1060.00),
(14, 'Savings', '2021-08-06', 180912, 560.00);

-- --------------------------------------------------------

--
-- Table structure for table `customers`
--

CREATE TABLE `customers` (
  `CustomerID` int(7) NOT NULL,
  `FirstName` varchar(255) DEFAULT NULL,
  `LastName` varchar(255) DEFAULT NULL,
  `DateofBirth` date DEFAULT NULL,
  `MobilePhone` varchar(255) DEFAULT NULL,
  `AddressID` int(7) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `customers`
--

INSERT INTO `customers` (`CustomerID`, `FirstName`, `LastName`, `DateofBirth`, `MobilePhone`, `AddressID`) VALUES
(1, 'Thom', 'Yorke', '2000-10-31', '07345612391', 1),
(2, 'Thomas', 'Kantlove', '1990-05-03', '07812459999', 2),
(3, 'Ed', 'Wood', '1955-12-05', '07723465123', 3),
(4, 'Peter', 'Parker', '1993-09-23', '07891209581', 4),
(5, 'Gwen', 'Parker', '1993-08-12', '07891209665', 4),
(6, 'Wes', 'Anderson', '1974-06-16', '07891076345', 5),
(7, 'Roger', 'Waters', '1943-05-13', '07534901291', 6),
(8, 'Adrian', 'Brody', '2001-01-01', '07612390191', 1),
(9, 'Mariah', 'Carey', '2000-12-25', '07123451030', 1),
(10, 'Michael', 'Appleton', '1985-02-09', '07791280125', 7),
(11, 'Kate', 'Bush', '1969-04-29', '07732910912', 6);

-- --------------------------------------------------------

--
-- Table structure for table `has`
--

CREATE TABLE `has` (
  `CustomerID` int(7) NOT NULL,
  `AccountID` int(7) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `has`
--

INSERT INTO `has` (`CustomerID`, `AccountID`) VALUES
(1, 1),
(2, 2),
(2, 12),
(3, 3),
(4, 4),
(5, 4),
(6, 5),
(7, 6),
(8, 7),
(9, 8),
(10, 9),
(11, 10),
(11, 11),
(7, 13),
(8, 14);

-- --------------------------------------------------------

--
-- Table structure for table `loans`
--

CREATE TABLE `loans` (
  `LoanID` int(7) NOT NULL,
  `StartPayment` date DEFAULT NULL,
  `MonthlyPaymentRate` float(6,2) DEFAULT NULL,
  `NumberOfPayments` int(2) DEFAULT NULL,
  `NextPayment` date DEFAULT NULL,
  `FullPaymentConfirmed` date DEFAULT NULL,
  `AccountID` int(7) NOT NULL,
  `DateLoanTaken` date DEFAULT NULL,
  `MonthlyDueDate` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `loans`
--

INSERT INTO `loans` (`LoanID`, `StartPayment`, `MonthlyPaymentRate`, `NumberOfPayments`, `NextPayment`, `FullPaymentConfirmed`, `AccountID`, `DateLoanTaken`, `MonthlyDueDate`) VALUES
(1, '2021-09-25', 160.00, 10, '2021-12-25', '2022-07-25', 1, '2021-08-15', '25th'),
(2, '2021-01-06', 200.00, 15, '2021-12-06', '2022-04-06', 3, '2020-12-13', '6th'),
(3, '2021-11-13', 70.00, 2, '2021-12-13', '2022-01-13', 3, '2021-10-05', '13th'),
(4, '2021-09-07', 160.00, 10, '2021-12-07', '2022-07-07', 8, '2021-08-01', '7th'),
(5, '2020-09-19', 100.00, 20, '2021-12-19', '2022-05-19', 9, '2020-08-17', '19th'),
(6, '2021-06-01', 120.00, 8, '2021-12-01', '2022-02-01', 10, '2021-05-01', '1st'),
(7, '2021-09-16', 180.00, 10, '2021-12-16', '2022-07-16', 7, '2021-08-16', '16th'),
(8, '2021-12-20', 500.00, 10, '2021-12-20', '2022-10-20', 6, '2021-11-20', '20th');

-- --------------------------------------------------------

--
-- Table structure for table `transactions`
--

CREATE TABLE `transactions` (
  `TransactionID` int(7) NOT NULL,
  `Description` varchar(255) DEFAULT NULL,
  `Amount` float(6,2) DEFAULT NULL,
  `isLoan` tinyint(1) DEFAULT NULL,
  `TransactionDate` date DEFAULT NULL,
  `AccountID` int(7) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `transactions`
--

INSERT INTO `transactions` (`TransactionID`, `Description`, `Amount`, `isLoan`, `TransactionDate`, `AccountID`) VALUES
(1, 'Opening Balance', 60.00, 0, '2021-07-19', 1),
(2, 'Student Loan Payment', 1600.00, 1, '2021-08-15', 1),
(3, 'Weekly Shop', -140.00, 0, '2021-10-07', 1),
(4, 'Buying a guitar', -300.00, 0, '2021-10-13', 1),
(5, 'Weekly Shop', -140.00, 0, '2021-10-14', 1),
(6, 'Weekly Shop', -140.00, 0, '2021-10-21', 1),
(7, 'Student Loan Repayment', -160.00, 1, '2021-10-25', 1),
(8, 'Weekly Shop', -140.00, 0, '2021-10-28', 1),
(9, 'Weekly Shop', -140.00, 0, '2021-11-04', 1),
(10, 'Weekly Shop', -140.00, 0, '2021-11-11', 1),
(11, 'Weekly Shop', -140.00, 0, '2021-11-18', 1),
(12, 'Weekly Shop', -140.00, 0, '2021-11-25', 1),
(13, 'Student Loan Repayment', -160.00, 1, '2021-11-25', 1),
(14, 'Student Loan Repayment', -160.00, 1, '2021-09-25', 1),
(15, 'Opening Balance', 60.00, 0, '2021-10-31', 2),
(16, 'Salary from Job', 2500.00, 0, '2021-11-01', 2),
(17, 'Restaurant Meal', -20.00, 0, '2021-11-01', 2),
(18, 'Mum\'s Birthday Gift', -50.00, 0, '2021-11-02', 2),
(19, 'Mum\'s Christmas Gift', -25.00, 0, '2021-11-03', 2),
(20, 'Weekly Shop', -20.00, 0, '2021-11-04', 2),
(21, 'Winning Scratchcard', 50.00, 0, '2021-11-05', 2),
(22, 'Dad\'s Christmas Gift', -75.00, 0, '2021-11-06', 2),
(23, 'Second Hand DVD Bought', -1.00, 0, '2021-11-07', 2),
(24, 'Restaurant Meal', -10.00, 0, '2021-11-08', 2),
(25, 'Brother\'s Christmas Gift', -10.00, 0, '2021-11-09', 2),
(26, 'Restaurant Meal', -10.00, 0, '2021-11-10', 2),
(27, 'Weekly Shop', -20.00, 0, '2021-11-11', 2),
(28, 'Bought Chocolates', -2.00, 0, '2021-11-12', 2),
(29, 'Found Money', 15.00, 0, '2021-11-13', 2),
(30, 'Second Hand DVD Bought', -0.50, 0, '2021-11-14', 2),
(31, 'Donation to Charity', -10.00, 0, '2021-11-15', 2),
(32, 'Donation to Charity', -5.00, 0, '2021-11-16', 2),
(33, 'Cinema Trip', -14.00, 0, '2021-11-17', 2),
(34, 'Weekly Shop', -20.00, 0, '2021-11-18', 2),
(35, 'Restaurant Meal', -10.00, 0, '2021-11-19', 2),
(36, 'Second Hand Video Game Bought', -4.00, 0, '2021-11-20', 2),
(37, 'Found Money', 10.00, 0, '2021-11-21', 2),
(38, 'Donation to Charity', -10.00, 0, '2021-11-22', 2),
(39, 'Bought Cake', -5.00, 0, '2021-11-23', 2),
(40, 'Bought New Clothes', -20.00, 0, '2021-11-24', 2),
(41, 'Weekly Shop', -20.00, 0, '2021-11-25', 2),
(42, 'Watched Show', -10.00, 0, '2021-11-26', 2),
(43, 'Second Hand DVD Bought', -1.00, 0, '2021-11-27', 2),
(44, 'Winning Scratchcard', 15.00, 0, '2021-11-28', 2),
(45, 'Donation to Charity', -2.00, 0, '2021-11-29', 2),
(46, 'Restaurant Meal', -30.00, 0, '2021-11-30', 2),
(47, 'Transfer to Savings', -1000.00, 0, '2021-11-30', 2),
(48, 'Opening Balance', 60.00, 0, '2020-11-16', 3),
(49, 'Business Loan', 3000.00, 1, '2020-12-13', 3),
(50, 'Business Start Up', -1000.00, 0, '2020-12-14', 3),
(51, 'Monthly Sales', 100.00, 0, '2020-12-31', 3),
(52, 'Business Loan Repayment', -200.00, 1, '2021-01-06', 3),
(53, 'Monthly Sales', 20.00, 0, '2021-01-31', 3),
(54, 'Business Loan Repayment', -200.00, 1, '2021-02-06', 3),
(55, 'Repair Computer', -500.00, 0, '2021-02-14', 3),
(56, 'Monthly Sales', 60.00, 0, '2021-02-28', 3),
(57, 'Business Loan Repayment', -200.00, 1, '2021-03-06', 3),
(58, 'Monthly Sales', 20.00, 0, '2021-03-31', 3),
(59, 'Business Loan Repayment', -200.00, 1, '2021-04-06', 3),
(60, 'Order More Materials', -500.00, 0, '2021-04-21', 3),
(61, 'Monthly Sales', 20.00, 0, '2021-04-30', 3),
(62, 'Business Loan Repayment', -200.00, 1, '2021-05-06', 3),
(63, 'Monthly Sales', 200.00, 0, '2021-05-31', 3),
(64, 'Business Loan Repayment', -200.00, 1, '2021-06-06', 3),
(65, 'Monthly Sales', 200.00, 0, '2021-06-30', 3),
(66, 'Business Loan Repayment', -200.00, 1, '2021-07-06', 3),
(67, 'Repair Light', -50.00, 0, '2021-07-10', 3),
(68, 'Monthly Sales', 100.00, 0, '2021-07-31', 3),
(69, 'Business Loan Repayment', -200.00, 1, '2021-08-06', 3),
(70, 'Monthly Sales', 40.00, 0, '2021-08-31', 3),
(71, 'Business Loan Repayment', -200.00, 1, '2021-09-06', 3),
(72, 'Replace Old Equipment', -500.00, 0, '2021-09-20', 3),
(73, 'Monthly Sales', 20.00, 0, '2021-09-30', 3),
(74, 'Short Term Loan', 140.00, 1, '2021-10-05', 3),
(75, 'Business Loan Repayment', -200.00, 1, '2021-10-06', 3),
(76, 'Monthly Sales', 200.00, 0, '2021-10-31', 3),
(77, 'Business Loan Repayment', -200.00, 1, '2021-11-06', 3),
(78, 'Short Term Loan Repayment', -70.00, 1, '2021-11-13', 3),
(79, 'Monthly Sales', 300.00, 0, '2021-11-30', 3),
(80, 'Opening Balance', 60.00, 0, '2021-05-05', 4),
(81, 'Peter\'s Bimonthly Salary', 1500.00, 0, '2021-05-08', 4),
(82, 'Restaurant Meal', -100.00, 0, '2021-05-15', 4),
(83, 'House Development', -1000.00, 0, '2021-05-26', 4),
(84, 'Gwen\'s Bimonthly Salary', 1500.00, 0, '2021-06-08', 4),
(85, 'Restaurant Meal', -150.00, 0, '2021-06-17', 4),
(86, 'New Pool', -1700.00, 0, '2021-06-23', 4),
(87, 'Peter\'s Bimonthly Salary', 1500.00, 0, '2021-07-08', 4),
(88, 'Birthday Celebration', -300.00, 0, '2021-07-13', 4),
(89, 'Restaurant Meal', -200.00, 0, '2021-07-20', 4),
(90, 'Gwen\'s Bimonthly Salary', 1500.00, 0, '2021-08-08', 4),
(91, 'Bought a Dog', -500.00, 0, '2021-08-16', 4),
(92, 'Donation to Charity', -1000.00, 0, '2021-08-25', 4),
(93, 'Peter\'s Bimonthly Salary', 1500.00, 0, '2021-09-08', 4),
(94, 'Donation to Charity', -1000.00, 0, '2021-09-12', 4),
(95, 'Gwen\'s Bimonthly Salary', 1500.00, 0, '2021-10-08', 4),
(96, 'New TV', -1250.00, 0, '2021-10-19', 4),
(97, 'Restaurant Meal', -200.00, 0, '2021-10-23', 4),
(98, 'Peter\'s Bimonthly Salary', 1500.00, 0, '2021-11-08', 4),
(99, 'Restaurant Meal', -300.00, 0, '2021-11-15', 4),
(100, 'Opening Balance', 60.00, 0, '2021-09-12', 5),
(101, 'Salary From Prior Job', 5000.00, 0, '2021-09-23', 5),
(102, 'Business Start Up', -2000.00, 0, '2021-09-24', 5),
(103, 'Monthly Sales', 35.00, 0, '2021-09-30', 5),
(104, 'Advertising Money', -1500.00, 0, '2021-10-10', 5),
(105, 'Monthly Sales', 350.00, 0, '2021-10-31', 5),
(106, 'Employed New Worker', -200.00, 0, '2021-11-26', 5),
(107, 'Monthly Sales', 700.00, 0, '2021-11-30', 5),
(108, 'Opening Balance', 60.00, 0, '2021-11-19', 6),
(109, 'Retirement Money', 2000.00, 0, '2021-11-28', 6),
(110, 'House Repairs', -500.00, 0, '2021-11-29', 6),
(111, 'Opening Balance', 60.00, 0, '2021-08-06', 7),
(112, 'Graduate Loan Payment', 1800.00, 1, '2021-08-16', 7),
(113, 'House Rent', -105.00, 0, '2021-08-23', 7),
(114, 'Weekly Shop', -10.00, 0, '2021-08-23', 7),
(115, 'Weekly Shop', -10.00, 0, '2021-08-30', 7),
(116, 'Monthly Salary', 200.00, 0, '2021-09-05', 7),
(117, 'Weekly Shop', -30.00, 0, '2021-09-06', 7),
(118, 'Bought New Clothes', -70.00, 0, '2021-09-11', 7),
(119, 'Weekly Shop', -20.00, 0, '2021-09-13', 7),
(120, 'Graduate Loan Repayment', -180.00, 1, '2021-09-16', 7),
(121, 'Weekly Shop', -20.00, 0, '2021-09-20', 7),
(122, 'House Rent', -105.00, 0, '2021-09-23', 7),
(123, 'Weekly Shop', -10.00, 0, '2021-09-27', 7),
(124, 'Weekly Shop', -20.00, 0, '2021-10-04', 7),
(125, 'Monthly Salary', 200.00, 0, '2021-10-05', 7),
(126, 'Weekly Shop', -10.00, 0, '2021-10-11', 7),
(127, 'Graduate Loan Repayment', -180.00, 1, '2021-10-16', 7),
(128, 'Weekly Shop', -15.00, 0, '2021-10-18', 7),
(129, 'House Rent', -105.00, 0, '2021-10-23', 7),
(130, 'Weekly Shop', -15.00, 0, '2021-10-25', 7),
(131, 'Weekly Shop', -15.00, 0, '2021-11-01', 7),
(132, 'Monthly Salary', 200.00, 0, '2021-11-05', 7),
(133, 'Weekly Shop', -20.00, 0, '2021-11-08', 7),
(134, 'Weekly Shop', -10.00, 0, '2021-11-15', 7),
(135, 'Graduate Loan Repayment', -180.00, 1, '2021-11-16', 7),
(136, 'Weekly Shop', -30.00, 0, '2021-11-22', 7),
(137, 'House Rent', -105.00, 0, '2021-11-23', 7),
(138, 'Weekly Shop', -15.00, 0, '2021-11-29', 7),
(139, 'Transfer to Savings', -500.00, 0, '2021-11-30', 7),
(140, 'Opening Balance', 60.00, 0, '2021-07-29', 8),
(141, 'Student Loan Payment', 1600.00, 1, '2021-08-01', 8),
(142, 'Bought a Microphone', -200.00, 0, '2021-08-15', 8),
(143, 'Weekly Shop', -20.00, 0, '2021-08-22', 8),
(144, 'Weekly Shop', -20.00, 0, '2021-08-29', 8),
(145, 'Monthly Salary', 300.00, 0, '2021-09-02', 8),
(146, 'Weekly Shop', -20.00, 0, '2021-09-05', 8),
(147, 'Student Loan Repayment', -160.00, 1, '2021-09-07', 8),
(148, 'Weekly Shop', -10.00, 0, '2021-09-12', 8),
(149, 'Weekly Shop', -20.00, 0, '2021-09-19', 8),
(150, 'Restaurant Meal', -7.00, 0, '2021-09-25', 8),
(151, 'Weekly Shop', -10.50, 0, '2021-09-26', 8),
(152, 'Monthly Salary', 300.00, 0, '2021-10-02', 8),
(153, 'Weekly Shop', -11.78, 0, '2021-10-03', 8),
(154, 'Student Loan Repayment', -160.00, 1, '2021-10-07', 8),
(155, 'Weekly Shop', -20.00, 0, '2021-10-10', 8),
(156, 'Weekly Shop', -13.89, 0, '2021-10-17', 8),
(157, 'Weekly Shop', -17.00, 0, '2021-10-24', 8),
(158, 'Weekly Shop', -10.00, 0, '2021-10-31', 8),
(159, 'Monthly Salary', 300.00, 0, '2021-11-02', 8),
(160, 'Dad\'s Birthday Gift', -100.00, 0, '2021-11-06', 8),
(161, 'Weekly Shop', -40.00, 0, '2021-11-07', 8),
(162, 'Student Loan Repayment', -160.00, 1, '2021-11-07', 8),
(163, 'Bought Drum Set', -400.50, 0, '2021-11-12', 8),
(164, 'Weekly Shop', -20.70, 0, '2021-11-14', 8),
(165, 'Weekly Shop', -20.00, 0, '2021-11-21', 8),
(166, 'Weekly Shop', -30.90, 0, '2021-11-28', 8),
(167, 'Transfer to Savings', -1000.00, 0, '2021-11-29', 6),
(168, 'Opening Balance', 60.00, 0, '2020-07-09', 9),
(169, 'Business Loan', 2000.00, 1, '2020-08-17', 9),
(170, 'Business Start Up', -500.00, 0, '2020-08-29', 9),
(171, 'Final Monthly Salary', 2000.00, 0, '2020-09-11', 9),
(172, 'Business Loan Repayment', -100.00, 1, '2020-09-19', 9),
(173, 'Business Loan Repayment', -100.00, 1, '2020-10-19', 9),
(174, 'Satisfied Client Request', 100.00, 0, '2020-10-20', 9),
(175, 'Business Loan Repayment', -100.00, 1, '2020-11-19', 9),
(176, 'Business Loan Repayment', -100.00, 1, '2020-12-19', 9),
(177, 'Satisfied Client Request', 350.00, 0, '2020-12-30', 9),
(178, 'Website Maintenance', -200.00, 0, '2021-01-09', 9),
(179, 'Business Loan Repayment', -100.00, 1, '2021-01-19', 9),
(180, 'Business Loan Repayment', -100.00, 1, '2021-02-19', 9),
(181, 'Satisfied Client Request', 200.00, 0, '2021-02-21', 9),
(182, 'Business Loan Repayment', -100.00, 1, '2021-03-19', 9),
(183, 'Satisfied Client Request', 200.00, 0, '2021-03-25', 9),
(184, 'Business Loan Repayment', -100.00, 1, '2021-04-19', 9),
(185, 'Business Loan Repayment', -100.00, 1, '2021-05-19', 9),
(186, 'Satisfied Client Request', 300.00, 0, '2021-06-03', 9),
(187, 'Business Loan Repayment', -100.00, 1, '2021-06-19', 9),
(188, 'Yearly Tax', -1000.00, 0, '2021-07-09', 9),
(189, 'Business Loan Repayment', -100.00, 1, '2021-07-19', 9),
(190, 'Satisfied Client Request', 600.00, 0, '2021-08-09', 9),
(191, 'Business Loan Repayment', -100.00, 1, '2021-08-19', 9),
(192, 'Business Loan Repayment', -100.00, 1, '2021-09-19', 9),
(193, 'Satisfied Client Request', 200.00, 0, '2021-10-19', 9),
(194, 'Business Loan Repayment', -100.00, 1, '2021-10-19', 9),
(195, 'Business Loan Repayment', -100.00, 1, '2021-11-19', 9),
(196, 'Opening Balance', 60.00, 0, '2021-04-12', 10),
(197, 'Restaurant Meal', -15.00, 0, '2021-04-21', 10),
(198, 'Regular Loan Payment', 960.00, 1, '2021-05-01', 10),
(199, 'Monthly Salary', 1250.00, 0, '2021-05-18', 10),
(200, 'Restaurant Meal', -20.00, 0, '2021-05-27', 10),
(201, 'Regular Loan Repayment', -120.00, 1, '2021-06-01', 10),
(202, 'Restaurant Meal', -20.00, 0, '2021-06-07', 10),
(203, 'Monthly Salary', 1250.00, 0, '2021-06-18', 10),
(204, 'Booked a Month Long Holiday', -2000.00, 0, '2021-06-25', 10),
(205, 'Regular Loan Repayment', -120.00, 1, '2021-07-01', 10),
(206, 'Duty Free Shopping', -40.00, 0, '2021-07-25', 10),
(207, 'Winning Scratchcard', 50.00, 0, '2021-07-28', 10),
(208, 'Regular Loan Repayment', -120.00, 1, '2021-08-01', 10),
(209, 'Monthly Salary', 1250.00, 0, '2021-08-18', 10),
(210, 'Bought New Sofa', -450.60, 0, '2021-08-25', 10),
(211, 'Regular Loan Repayment', -120.00, 1, '2021-09-01', 10),
(212, 'Restaurant Meal', -30.00, 0, '2021-09-09', 10),
(213, 'Monthly Salary', 1250.00, 0, '2021-09-18', 10),
(214, 'Had Weekend Trip', -500.20, 0, '2021-09-25', 10),
(215, 'Regular Loan Repayment', -120.00, 1, '2021-10-01', 10),
(216, 'Visited Premier League Match', -280.90, 0, '2021-10-16', 10),
(217, 'Monthly Salary', 1250.00, 0, '2021-10-18', 10),
(218, 'Regular Loan Repayment', -120.00, 1, '2021-11-01', 10),
(219, 'Monthly Salary', 1250.00, 0, '2021-11-18', 10),
(220, 'Bought New House', -3000.00, 0, '2021-11-27', 10),
(221, 'Transfer to Savings Account', -1250.00, 0, '2021-11-28', 10),
(222, 'Opening Balance', 60.00, 0, '2021-04-12', 11),
(223, 'Money Received From Current Account', 1250.00, 0, '2021-11-28', 11),
(224, 'Opening Balance', 60.00, 0, '2021-10-31', 12),
(225, 'Money Received From Current Account', 1000.00, 0, '2021-11-30', 12),
(226, 'Opening Balance', 60.00, 0, '2021-11-19', 13),
(227, 'Money Received from Current Account', 1000.00, 0, '2021-11-29', 13),
(228, 'Opening Balance', 60.00, 0, '2021-08-06', 14),
(229, 'Money Received from Graduate Account', 500.00, 0, '2021-11-30', 14),
(230, 'Lottery Winnings', 5000.00, 0, '2021-11-30', 2),
(231, 'Regular Loan Payment', 5000.00, 1, '2021-11-20', 6);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `addresses`
--
ALTER TABLE `addresses`
  ADD PRIMARY KEY (`AddressID`);

--
-- Indexes for table `bankaccounts`
--
ALTER TABLE `bankaccounts`
  ADD PRIMARY KEY (`AccountID`);

--
-- Indexes for table `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`CustomerID`),
  ADD KEY `AddressID` (`AddressID`);

--
-- Indexes for table `has`
--
ALTER TABLE `has`
  ADD KEY `CustomerID` (`CustomerID`),
  ADD KEY `AccountID` (`AccountID`);

--
-- Indexes for table `loans`
--
ALTER TABLE `loans`
  ADD PRIMARY KEY (`LoanID`),
  ADD KEY `AccountID` (`AccountID`);

--
-- Indexes for table `transactions`
--
ALTER TABLE `transactions`
  ADD PRIMARY KEY (`TransactionID`),
  ADD KEY `AccountID` (`AccountID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `addresses`
--
ALTER TABLE `addresses`
  MODIFY `AddressID` int(7) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `bankaccounts`
--
ALTER TABLE `bankaccounts`
  MODIFY `AccountID` int(7) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `customers`
--
ALTER TABLE `customers`
  MODIFY `CustomerID` int(7) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `loans`
--
ALTER TABLE `loans`
  MODIFY `LoanID` int(7) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `transactions`
--
ALTER TABLE `transactions`
  MODIFY `TransactionID` int(7) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=232;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `customers`
--
ALTER TABLE `customers`
  ADD CONSTRAINT `customers_ibfk_1` FOREIGN KEY (`AddressID`) REFERENCES `addresses` (`AddressID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `has`
--
ALTER TABLE `has`
  ADD CONSTRAINT `has_ibfk_1` FOREIGN KEY (`CustomerID`) REFERENCES `customers` (`CustomerID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `has_ibfk_2` FOREIGN KEY (`AccountID`) REFERENCES `bankaccounts` (`AccountID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `loans`
--
ALTER TABLE `loans`
  ADD CONSTRAINT `loans_ibfk_1` FOREIGN KEY (`AccountID`) REFERENCES `bankaccounts` (`AccountID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `transactions`
--
ALTER TABLE `transactions`
  ADD CONSTRAINT `transactions_ibfk_1` FOREIGN KEY (`AccountID`) REFERENCES `bankaccounts` (`AccountID`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
