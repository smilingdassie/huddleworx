USE [master]
GO
/****** Object:  Database [HuddleSmtp]    Script Date: 2022/08/26 03:24:42 PM ******/
CREATE DATABASE [HuddleSmtp]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'HuddleSmtp', FILENAME = N'D:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\HuddleSmtp.mdf' , SIZE = 3088384KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'HuddleSmtp_log', FILENAME = N'D:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\HuddleSmtp_log.ldf' , SIZE = 6299648KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [HuddleSmtp] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [HuddleSmtp].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [HuddleSmtp] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [HuddleSmtp] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [HuddleSmtp] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [HuddleSmtp] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [HuddleSmtp] SET ARITHABORT OFF 
GO
ALTER DATABASE [HuddleSmtp] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [HuddleSmtp] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [HuddleSmtp] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [HuddleSmtp] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [HuddleSmtp] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [HuddleSmtp] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [HuddleSmtp] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [HuddleSmtp] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [HuddleSmtp] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [HuddleSmtp] SET  DISABLE_BROKER 
GO
ALTER DATABASE [HuddleSmtp] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [HuddleSmtp] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [HuddleSmtp] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [HuddleSmtp] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [HuddleSmtp] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [HuddleSmtp] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [HuddleSmtp] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [HuddleSmtp] SET RECOVERY FULL 
GO
ALTER DATABASE [HuddleSmtp] SET  MULTI_USER 
GO
ALTER DATABASE [HuddleSmtp] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [HuddleSmtp] SET DB_CHAINING OFF 
GO
ALTER DATABASE [HuddleSmtp] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [HuddleSmtp] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [HuddleSmtp] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [HuddleSmtp] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'HuddleSmtp', N'ON'
GO
ALTER DATABASE [HuddleSmtp] SET QUERY_STORE = OFF
GO
USE [HuddleSmtp]
GO
/****** Object:  UserDefinedFunction [dbo].[CharCount]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[CharCount]
(@string VARCHAR(MAX)='Noida, short for the New Okhla Industrial Development Authority, is a planned city in India under the management of the New Okhla Industrial Development Authority.It is part of National Capital Region of India.'
,@tosearch VARCHAR(MAX)='In'  
)
returns int
begin
declare @output int
SELECT @output =(DATALENGTH(@string)-DATALENGTH(REPLACE(@string,@tosearch,'')))/DATALENGTH(@tosearch)  
--AS OccurrenceCount  

return @output
end
GO
/****** Object:  UserDefinedFunction [dbo].[EmailDate]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[EmailDate]
(@sender VARCHAR(2000)
,@receiver VARCHAR(2000), @firstOrLast varchar(200)
)
returns datetime
begin
declare @output datetime, @last dateTime, @first datetime

select @first=  min(DateTimeSent), @last = max(DateTimeSent)
from SentEmail
where replace(replace(FromEmail,';',''),' ','') = replace(replace(@sender,';',''),' ','')
and replace(replace(ToEmail,';',''),' ','') = replace(replace(@receiver,';',''),' ','')

if @firstOrLast = 'first'
SELECT @output   = @first
else
select @output = @last

return @output
end


GO
/****** Object:  UserDefinedFunction [dbo].[GetDisplayNameFromEmail]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[GetDisplayNameFromEmail]
(@string VARCHAR(MAX)='Malcolm.deBruyn@sead.co.za')

returns varchar(2000)
begin
declare @output varchar(2000) ='', @id int, @item varchar(2000), @userEmail varchar(2000)
 
	if(PATINDEX('%sead.co.za%',@string)>0)
	begin
		select @item =  substring(@string,1, charindex('@',@string)-1)
		select @userEmail = replace(@item,'.',' ')
	end
return @userEmail
--select @output
end

GO
/****** Object:  UserDefinedFunction [dbo].[GetEmailFromDisplayName]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[GetEmailFromDisplayName]
(@string VARCHAR(MAX)='Bandile Ndlazi;Carmen Jallow')

returns varchar(2000)
begin
declare @output varchar(2000) ='', @id int, @item varchar(2000), @userEmail varchar(2000)
declare @table table (ID int identity primary key, Item varchar(2000))
insert into @table(Item) select * from [dbo].[SplitStrings_CTE](@string, ';')
while exists(select * from @table)
begin
	select top 1 @id = ID from @table order by ID
	select @item = Item from @table where ID = @id
	select @userEmail = UserEmail from UserPrincipalTable where DisplayName =  @item

	if(len(ISNULL(@userEmail,''))=0) 
	begin
		select @userEmail = ToEmail from RecipientList where replace(ToEmailNames,';','') =  @item
		and ToEmail like '%@sead.co.za'
		if(len(ISNULL(@userEmail,''))=0) 
			select @userEmail = replace(ToEmail,';','') from RecipientList where replace(ToEmailNames,';','') =  @item
			and ToEmail like '%@%'
--			select @userEmail as bob, @item as item
		if(len(ISNULL(@userEmail,''))=0) 
		BEGIN
			set @userEmail = @item
		END
	end
	if(len(isnull(@userEmail,''))=0) set @userEmail = @string
	select top 1 @output = @output + @UserEmail + ';'
	delete from @table where ID = @id
end

return @output
--select @output
end

GO
/****** Object:  UserDefinedFunction [dbo].[GetEmailFromUserName]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[GetEmailFromUserName]
(@string VARCHAR(MAX)='DebraL@sead.co.za')

returns varchar(2000)
begin
declare @output varchar(2000) ='', @id int, @item varchar(2000), @userEmail varchar(2000)
 

	select @userEmail = DisplayName from UserPrincipalTable where UserEmail =  @string
	select @userEmail = replace(@userEmail,' ','.')+'@sead.co.za'

return @userEmail
--select @output
end

GO
/****** Object:  UserDefinedFunction [dbo].[HomogenizeUser]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[HomogenizeUser]
(
@inputuser varchar(2000)
)
returns varchar(2000)
as
begin
	declare @output varchar(2000)
	select @inputuser = replace(@inputuser,'mailto:','')
	if exists(select * from vwUserEmailMap where FromEmail = @inputuser)
	begin
		select @output = UserEmail from vwUserEmailMap where fromEmail = @inputuser
	end
	else
	begin
		select @output = @inputuser
	end

	return @output
end
GO
/****** Object:  Table [dbo].[SentMailSingleRecipients]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SentMailSingleRecipients](
	[ID] [int] NULL,
	[UserEmail] [varchar](2000) NULL,
	[ToEmail] [varchar](2000) NULL,
	[Subject] [varchar](2000) NULL,
	[DateTimeSent] [datetime] NULL,
	[ParentID] [int] NULL,
	[UserFullName] [varchar](400) NULL,
	[ToFullName] [varchar](400) NULL,
	[AlternativeToEmail] [varchar](400) NULL,
	[RecipientCount] [int] NULL,
	[Sender] [varchar](200) NULL
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vwFirstLastSentMail]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[vwFirstLastSentMail]
as
select 
UserFullName,
min(DateTimeSent) as FirstSentDate, max(DateTimeSent) as LastSentDate
from SentMailSingleRecipients
where DateTimeSent >= '1 May 2021' and DateTimeSent <= '31 December 2021'
group by UserFullName
GO
/****** Object:  Table [dbo].[SentEmail]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SentEmail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserPrincipalID] [int] NULL,
	[UserEmail] [varchar](200) NULL,
	[FromEmail] [varchar](200) NULL,
	[ToEmail] [nvarchar](max) NULL,
	[CCEmail] [nvarchar](max) NULL,
	[BCCEmail] [nvarchar](max) NULL,
	[Subject] [varchar](2000) NULL,
	[DateTimeSent] [datetime] NULL,
	[DateTimeImported] [datetime] NULL,
	[Sender] [varchar](2000) NULL,
	[ToEmailNames] [nvarchar](max) NULL,
	[CCEmailNames] [nvarchar](max) NULL,
	[BCCEmailNames] [nvarchar](max) NULL,
	[RecipientCount] [int] NULL,
 CONSTRAINT [PK__SentEmai__3214EC2763DFF51B] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Users]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[UserEmail] [varchar](2000) NULL,
	[UserID] [varchar](2000) NULL,
	[DisplayName] [varchar](2000) NULL
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[UsersNotDoneYet]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[UsersNotDoneYet]
as
SELECT ISNULL(ROW_NUMBER() OVER (ORDER BY a.UserEmail), 0) AS UniqueId, a.UserEmail, a.UserID, a.DisplayName
from Users a
left join SentEmail e
on a.UserEmail = e.UserEmail
where e.UserEmail is null
group by a.UserEmail, a.UserID, a.DisplayName
GO
/****** Object:  Table [dbo].[InboxEmail]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InboxEmail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserPrincipalID] [int] NULL,
	[UserEmail] [varchar](200) NULL,
	[FromEmail] [varchar](200) NULL,
	[ToEmail] [nvarchar](max) NULL,
	[CCEmail] [nvarchar](max) NULL,
	[BCCEmail] [nvarchar](max) NULL,
	[Subject] [varchar](2000) NULL,
	[DateTimeSent] [datetime] NULL,
	[DateTimeImported] [datetime] NULL,
	[Sender] [varchar](2000) NULL,
	[ToEmailNames] [nvarchar](max) NULL,
	[CCEmailNames] [nvarchar](max) NULL,
	[BCCEmailNames] [nvarchar](max) NULL,
	[RecipientCount] [int] NULL,
 CONSTRAINT [PK__INboxEmai__3214EC2763DFF51B] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[UserNotDoneYetInbox]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[UserNotDoneYetInbox]
as
SELECT ISNULL(ROW_NUMBER() OVER (ORDER BY a.UserEmail), 0) AS UniqueId, a.UserEmail, a.UserID, a.DisplayName
from Users a
left join InboxEmail e
on a.UserEmail = e.UserEmail
where e.UserEmail is null
group by a.UserEmail, a.UserID, a.DisplayName

GO
/****** Object:  View [dbo].[vwUserEmailMap]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vwUserEmailMap]
as
select * from (
select UserEmail, FromEmail 
from SentEmail b
where Charindex('@', UserEmail)>0 and CHARINDEX('.',FromEmail)>0
)a
where left(a.UserEmail,charindex('@',a.UserEmail)-1) = left(a.FromEmail,charindex('.',a.FromEmail)-1) + Substring(a.FromEmail,charindex('.',a.FromEmail)+1,1)
and a.UserEmail like '%@sead.co.za' and a.FromEmail like '%sead.co.za'
group by UserEmail, FromEmail

 

GO
/****** Object:  UserDefinedFunction [dbo].[SplitStrings_CTE]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create FUNCTION [dbo].[SplitStrings_CTE]
(
   @List       NVARCHAR(MAX),
   @Delimiter  NVARCHAR(255)
)
RETURNS @Items TABLE (Item NVARCHAR(4000))
WITH SCHEMABINDING
AS
BEGIN
   DECLARE @ll INT = LEN(@List) + 1, @ld INT = LEN(@Delimiter);
 
   WITH a AS
   (
       SELECT
           [start] = 1,
           [end]   = COALESCE(NULLIF(CHARINDEX(@Delimiter, 
                       @List, 1), 0), @ll),
           [value] = SUBSTRING(@List, 1, 
                     COALESCE(NULLIF(CHARINDEX(@Delimiter, 
                       @List, 1), 0), @ll) - 1)
       UNION ALL
       SELECT
           [start] = CONVERT(INT, [end]) + @ld,
           [end]   = COALESCE(NULLIF(CHARINDEX(@Delimiter, 
                       @List, [end] + @ld), 0), @ll),
           [value] = SUBSTRING(@List, [end] + @ld, 
                     COALESCE(NULLIF(CHARINDEX(@Delimiter, 
                       @List, [end] + @ld), 0), @ll)-[end]-@ld)
       FROM a
       WHERE [end] < @ll
   )
   INSERT @Items SELECT LTRIM(RTRIM([value]))
   FROM a
   WHERE LEN([value]) > 0
   OPTION (MAXRECURSION 0);
 
   RETURN;
END

GO
/****** Object:  Table [dbo].[AmandaSentEmail]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AmandaSentEmail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserPrincipalID] [int] NULL,
	[UserEmail] [varchar](200) NULL,
	[FromEmail] [varchar](200) NULL,
	[ToEmail] [nvarchar](max) NULL,
	[CCEmail] [nvarchar](max) NULL,
	[BCCEmail] [nvarchar](max) NULL,
	[Subject] [varchar](2000) NULL,
	[DateTimeSent] [datetime] NULL,
	[DateTimeImported] [datetime] NULL,
	[Sender] [varchar](2000) NULL,
	[ToEmailNames] [nvarchar](max) NULL,
	[CCEmailNames] [nvarchar](max) NULL,
	[BCCEmailNames] [nvarchar](max) NULL,
	[RecipientCount] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AmandaSentMailSingleRecipients]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AmandaSentMailSingleRecipients](
	[ID] [int] NULL,
	[UserEmail] [varchar](2000) NULL,
	[ToEmail] [varchar](2000) NULL,
	[Subject] [varchar](2000) NULL,
	[DateTimeSent] [datetime] NULL,
	[ParentID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ANILPST$]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ANILPST$](
	[Date] [datetime] NULL,
	[ User] [nvarchar](255) NULL,
	[ Sender] [nvarchar](255) NULL,
	[ From] [nvarchar](255) NULL,
	[ Subject] [nvarchar](255) NULL,
	[ Recipients] [nvarchar](max) NULL,
	[ CC Recipients] [nvarchar](255) NULL,
	[ BCC Recipients] [nvarchar](255) NULL,
	[ RecipientNames] [nvarchar](255) NULL,
	[ CC RecipientNames] [nvarchar](255) NULL,
	[ BCC RecipientNames] [nvarchar](255) NULL,
	[F12] [nvarchar](255) NULL,
	[F13] [nvarchar](255) NULL,
	[F14] [nvarchar](255) NULL,
	[F15] [nvarchar](255) NULL,
	[F16] [nvarchar](255) NULL,
	[F17] [nvarchar](255) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AnilSentEmail2]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AnilSentEmail2](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserPrincipalID] [int] NULL,
	[UserEmail] [varchar](200) NULL,
	[FromEmail] [varchar](200) NULL,
	[ToEmail] [nvarchar](max) NULL,
	[CCEmail] [nvarchar](max) NULL,
	[BCCEmail] [nvarchar](max) NULL,
	[Subject] [varchar](2000) NULL,
	[DateTimeSent] [datetime] NULL,
	[DateTimeImported] [datetime] NULL,
	[Sender] [varchar](2000) NULL,
	[ToEmailNames] [nvarchar](max) NULL,
	[CCEmailNames] [nvarchar](max) NULL,
	[BCCEmailNames] [nvarchar](max) NULL,
	[RecipientCount] [int] NULL,
 CONSTRAINT [PK__SewwntEmai__3214EC2763DFF51B] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AnilSentMail]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AnilSentMail](
	[Subject] [nvarchar](255) NULL,
	[F2] [nvarchar](255) NULL,
	[From: (Name)] [nvarchar](255) NULL,
	[From: (Address)] [nvarchar](255) NULL,
	[From: (Type)] [nvarchar](255) NULL,
	[To: (Name)] [nvarchar](255) NULL,
	[To: (Address)] [nvarchar](max) NULL,
	[To: (Type)] [nvarchar](255) NULL,
	[CC: (Name)] [nvarchar](255) NULL,
	[CC: (Address)] [nvarchar](255) NULL,
	[CC: (Type)] [nvarchar](255) NULL,
	[BCC: (Name)] [nvarchar](255) NULL,
	[BCC: (Address)] [nvarchar](255) NULL,
	[BCC: (Type)] [nvarchar](255) NULL,
	[Billing Information] [nvarchar](255) NULL,
	[Categories] [nvarchar](255) NULL,
	[Importance] [nvarchar](255) NULL,
	[Mileage] [nvarchar](255) NULL,
	[Sensitivity] [nvarchar](255) NULL,
	[ToEmail] [varchar](2000) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AnilSentMailoLD]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AnilSentMailoLD](
	[Subject] [nvarchar](255) NULL,
	[F2] [nvarchar](255) NULL,
	[From: (Name)] [nvarchar](255) NULL,
	[From: (Address)] [nvarchar](255) NULL,
	[From: (Type)] [nvarchar](255) NULL,
	[To: (Name)] [nvarchar](255) NULL,
	[To: (Address)] [nvarchar](max) NULL,
	[To: (Type)] [nvarchar](255) NULL,
	[CC: (Name)] [nvarchar](255) NULL,
	[CC: (Address)] [nvarchar](255) NULL,
	[CC: (Type)] [nvarchar](255) NULL,
	[BCC: (Name)] [nvarchar](255) NULL,
	[BCC: (Address)] [nvarchar](255) NULL,
	[BCC: (Type)] [nvarchar](255) NULL,
	[Billing Information] [nvarchar](255) NULL,
	[Categories] [nvarchar](255) NULL,
	[Importance] [nvarchar](255) NULL,
	[Mileage] [nvarchar](255) NULL,
	[Sensitivity] [nvarchar](255) NULL,
	[ToEmail] [varchar](2000) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ANILSENTSMTP]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ANILSENTSMTP](
	[Date] [datetime] NULL,
	[UserEmail] [varchar](21) NOT NULL,
	[FromAddress] [varchar](21) NOT NULL,
	[Subject] [nvarchar](255) NULL,
	[RecipientNames] [nvarchar](255) NULL,
	[CCRecipientNames] [nvarchar](255) NULL,
	[BCCRecipientNames] [nvarchar](255) NULL,
	[ToEmailNames] [nvarchar](max) NULL,
	[CCEmailNames] [nvarchar](max) NULL,
	[BCCEmailNames] [nvarchar](max) NULL,
	[RecipientCount] [int] NULL,
	[ToEmail] [varchar](2000) NULL,
	[CC] [varchar](2000) NULL,
	[BCC] [varchar](2000) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[backupusers]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[backupusers](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserEmail] [varchar](2000) NULL,
	[UserID] [varchar](2000) NULL,
	[DateTimeImported] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[backupusers1]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[backupusers1](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserEmail] [varchar](2000) NULL,
	[UserID] [varchar](2000) NULL,
	[DateTimeImported] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ChonkyMap]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChonkyMap](
	[ToEmail] [varchar](2000) NULL,
	[FullNameCalc] [varchar](28) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ChonkyMap2]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChonkyMap2](
	[ToEmail] [varchar](2000) NULL,
	[FullNameCalc] [varchar](8000) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ExceptionLog]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ExceptionLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [varchar](3000) NULL,
	[ErrorMessage1] [nvarchar](max) NULL,
	[ErrorMessage2] [nvarchar](max) NULL,
	[DateTimeLogged] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InboxBk15Feb]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InboxBk15Feb](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserPrincipalID] [int] NULL,
	[UserEmail] [varchar](200) NULL,
	[FromEmail] [varchar](200) NULL,
	[ToEmail] [nvarchar](max) NULL,
	[CCEmail] [nvarchar](max) NULL,
	[BCCEmail] [nvarchar](max) NULL,
	[Subject] [varchar](2000) NULL,
	[DateTimeSent] [datetime] NULL,
	[DateTimeImported] [datetime] NULL,
	[Sender] [varchar](2000) NULL,
	[ToEmailNames] [nvarchar](max) NULL,
	[CCEmailNames] [nvarchar](max) NULL,
	[BCCEmailNames] [nvarchar](max) NULL,
	[RecipientCount] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RecipientList]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RecipientList](
	[ToEmail] [varchar](2000) NULL,
	[ToEmailNames] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[sentEmailBackUp27Jan2021]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sentEmailBackUp27Jan2021](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserPrincipalID] [int] NULL,
	[UserEmail] [varchar](200) NULL,
	[FromEmail] [varchar](200) NULL,
	[ToEmail] [varchar](2000) NULL,
	[CCEmail] [varchar](2000) NULL,
	[BCCEmail] [varchar](2000) NULL,
	[Subject] [varchar](2000) NULL,
	[DateTimeSent] [datetime] NULL,
	[DateTimeImported] [datetime] NULL,
	[Sender] [varchar](2000) NULL,
	[ToEmailNames] [nvarchar](max) NULL,
	[CCEmailNames] [nvarchar](max) NULL,
	[BCCEmailNames] [nvarchar](max) NULL,
	[RecipientCount] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SentEmailBk15Feb]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SentEmailBk15Feb](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserPrincipalID] [int] NULL,
	[UserEmail] [varchar](200) NULL,
	[FromEmail] [varchar](200) NULL,
	[ToEmail] [nvarchar](max) NULL,
	[CCEmail] [nvarchar](max) NULL,
	[BCCEmail] [nvarchar](max) NULL,
	[Subject] [varchar](2000) NULL,
	[DateTimeSent] [datetime] NULL,
	[DateTimeImported] [datetime] NULL,
	[Sender] [varchar](2000) NULL,
	[ToEmailNames] [nvarchar](max) NULL,
	[CCEmailNames] [nvarchar](max) NULL,
	[BCCEmailNames] [nvarchar](max) NULL,
	[RecipientCount] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SentEmailFormatAnil]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SentEmailFormatAnil](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserPrincipalID] [int] NULL,
	[UserEmail] [varchar](200) NULL,
	[FromEmail] [varchar](200) NULL,
	[ToEmail] [varchar](2000) NULL,
	[CCEmail] [varchar](2000) NULL,
	[BCCEmail] [varchar](2000) NULL,
	[Subject] [varchar](2000) NULL,
	[DateTimeSent] [datetime] NULL,
	[DateTimeImported] [datetime] NULL,
	[Sender] [varchar](2000) NULL,
	[ToEmailNames] [nvarchar](max) NULL,
	[CCEmailNames] [nvarchar](max) NULL,
	[BCCEmailNames] [nvarchar](max) NULL,
	[RecipientCount] [int] NULL,
 CONSTRAINT [PK__SentEmaiAn__3214EC2763DFF51B] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[sentMailBackup]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sentMailBackup](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserPrincipalID] [int] NULL,
	[UserEmail] [varchar](2000) NULL,
	[FromEmail] [varchar](2000) NULL,
	[ToEmail] [varchar](2000) NULL,
	[CCEmail] [varchar](2000) NULL,
	[BCCEmail] [varchar](2000) NULL,
	[Subject] [varchar](2000) NULL,
	[DateTimeSent] [datetime] NULL,
	[DateTimeImported] [datetime] NULL,
	[Sender] [varchar](2000) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SentMailSinglesBak15Feb]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SentMailSinglesBak15Feb](
	[ID] [int] NULL,
	[UserEmail] [varchar](2000) NULL,
	[ToEmail] [varchar](2000) NULL,
	[Subject] [varchar](2000) NULL,
	[DateTimeSent] [datetime] NULL,
	[ParentID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SMB25Jan]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SMB25Jan](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserPrincipalID] [int] NULL,
	[UserEmail] [varchar](2000) NULL,
	[FromEmail] [varchar](2000) NULL,
	[ToEmail] [varchar](2000) NULL,
	[CCEmail] [varchar](2000) NULL,
	[BCCEmail] [varchar](2000) NULL,
	[Subject] [varchar](2000) NULL,
	[DateTimeSent] [datetime] NULL,
	[DateTimeImported] [datetime] NULL,
	[Sender] [varchar](2000) NULL,
	[ToEmailNames] [nvarchar](max) NULL,
	[CCEmailNames] [nvarchar](max) NULL,
	[BCCEmailNames] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[up3]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[up3](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserEmail] [varchar](2000) NULL,
	[UserID] [varchar](2000) NULL,
	[DateTimeImported] [datetime] NULL,
	[DisplayName] [varchar](2000) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[userBackup27Jan2021]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[userBackup27Jan2021](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserEmail] [varchar](2000) NULL,
	[UserID] [varchar](2000) NULL,
	[DateTimeImported] [datetime] NULL,
	[DisplayName] [varchar](2000) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserPrincipal]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserPrincipal](
	[UniqueId] [bigint] NOT NULL,
	[UserEmail] [varchar](8000) NULL,
 CONSTRAINT [PK_UserPrincipal] PRIMARY KEY CLUSTERED 
(
	[UniqueId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserPrincipalTable]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserPrincipalTable](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserEmail] [varchar](2000) NULL,
	[UserID] [varchar](200) NULL,
	[DateTimeIMported] [datetime] NULL,
	[DisplayName] [varchar](2000) NULL,
	[AlternativeEmail] [varchar](200) NULL,
	[AlternativeEmail2] [varchar](200) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [NonClusteredIndex-20220126-063151]    Script Date: 2022/08/26 03:24:43 PM ******/
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20220126-063151] ON [dbo].[SentEmail]
(
	[RecipientCount] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [NonClusteredIndex-20220126-064015]    Script Date: 2022/08/26 03:24:43 PM ******/
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20220126-064015] ON [dbo].[SentEmail]
(
	[UserEmail] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[SeadAggregateSentMail]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[SeadAggregateSentMail]
@sender varchar(2000)='debra lakay'
as

--select * from vwFirstLastSentMail order by UserEmail

declare @Aggregation table 
(
PairID int,
SenderID int,
RecipientID int,
Sender varchar(2000),
Recipient varchar(2000),
PairHash varchar(2000),
ReversePairHash varchar(2000),
FromEmail varchar(2000),
SenderEmail varchar(2000), 
RecipientEmail varchar(2000), 
SenderNumberOfEmailsSent int, 
RecipientNumberOfEmailsSent int, 
TotalVolume int,
SenderFirstSentDate datetime,
SenderLastSentDate datetime,
RecipientFirstSentDate datetime,
RecipientLastSentDate datetime
)

update SentMailSingleRecipients set ToEmail = ltrim(rtrim(ToEmail))
update SentMailSingleRecipients set UserEmail = ltrim(rtrim(UserEmail))




insert into @Aggregation(PairHash,ReversePairHash,SenderEmail, RecipientEmail, SenderNumberOfEmailsSent)

select  UserEmail+'|'+ToEmail as PairHash, ToEmail+'|'+UserEmail as ReversePairHash, * from (

select UserEmail, ToEmail,Count(*) NumberOfEmailsSent  from 
(
select dbo.HomogenizeUser(replace(UserEmail,';','')) as UserEmail,  
dbo.HomogenizeUser(replace(ToEmail,';','')) as ToEmail
--,UserEmail
--ToEmail
from SentMailSingleRecipients
where DateTimeSent > '1 May 2021'
and charindex('@',ToEmail)>0
)f
group by UserEmail, ToEmail
)x
order by UserEmail, ToEmail


update a set FromEmail = v.FromEmail
from @Aggregation a join vwUserEmailMap v
on a.SenderEmail = v.UserEmail
update @Aggregation set FromEmail = SenderEmail where FromEmail is null

update a 
set SenderFirstSentDate = v.FirstSentDate, SenderLastSentDate = v.LastSentDate
from @Aggregation a
join vwFirstLastSentMail v on a.SenderEmail = v.UserEmail

update a 
set RecipientFirstSentDate = v.FirstSentDate, RecipientLastSentDate = v.LastSentDate
from @Aggregation a
join vwFirstLastSentMail v on a.RecipientEmail = v.UserEmail


--select 'a1',* from @aggregation

--find recipients that are senders
update recip
set recip.RecipientNumberOfEmailsSent = sender.SenderNumberOfEmailsSent
--select recip.RecipientEmail, sender.SenderEmail, * 
from  @Aggregation recip
join @Aggregation sender
on recip.RecipientEmail = sender.SenderEmail
and recip.SenderEmail = sender.RecipientEmail

update @Aggregation set RecipientNumberOfEmailsSent = isnull(RecipientNumberOfEmailsSent,0)
update @Aggregation set TotalVolume = SenderNumberOfEmailsSent + RecipientNumberOfEmailsSent

update a
set SenderID = ID 
from @Aggregation  a
join UserPrincipalTable b on a.SenderEmail=b.UserEmail



update a
set RecipientID = ID 
from @Aggregation  a
join UserPrincipalTable b on a.RecipientEmail=b.UserEmail

declare @PairID int=1,@senderid int, @recipid int




--select 'r+1',* from @Aggregation where  recipientEmail = 'HlolisileK@sead.co.za'
--select 's+1',* from @Aggregation where  senderemail = 'HlolisileK@sead.co.za'
--select 'phs+1',* from @Aggregation where  PairHash like 'HlolisileK@sead.co.za%'
--select 'phs+1',* from @Aggregation where  PairHash like '%HlolisileK@sead.co.za'
--select * from UserPrincipalTable where UserEmail like '%hlol%'

--select 'ash',* from @Aggregation where SenderEmail like '%ashraf%@sead.co.za' --and recipientemail like '%hloli%'
--select 'ash',* from @Aggregation where RecipientEmail like '%ashraf%@sead.co.za' --

declare fr cursor for select a.SenderID, a.RecipientID
from @Aggregation a join @Aggregation b on 
a.PairHash = b.ReversePairHash
order by a.senderID, a.RecipientID
open fr
fetch next from fr into @senderid, @recipid
while @@FETCH_STATUS=0
begin
	
	update @Aggregation set PairID = @PairID
	where SenderID = @senderid and RecipientID = @recipid
	and PairID is null

	update @Aggregation set PairID = @PairID
	where SenderID = @recipid and RecipientID = @senderid
	and PairID is null
	--increment pair id
	set @PairID = @PairID +1

	fetch next from fr into @senderid, @recipid
end
close fr
deallocate fr

declare @PairID2 int

declare fr cursor for select a.PairID, a.SenderID, a.RecipientID
from @Aggregation a join @Aggregation b on 
a.PairHash = b.ReversePairHash
where a.PairID is not null
order by a.senderID, a.RecipientID
open fr
fetch next from fr into @Pairid2, @senderid, @recipid
while @@FETCH_STATUS=0
begin
	
	--update @Aggregation set PairID = @PairID
	--where SenderID = @senderid and RecipientID = @recipid
	--and PairID is null

	update @Aggregation set PairID = @Pairid2
	where SenderID = @recipid and RecipientID = @senderid
	and PairID is null
	
	fetch next from fr into @Pairid2, @senderid, @recipid
end
close fr
deallocate fr


--select 'a2', * from @Aggregation

update a
set Sender = b.DisplayName
from @Aggregation a join UserPrincipalTable b on a.SenderEmail = b.UserEmail

update a
set Recipient = b.DisplayName
from @Aggregation a join UserPrincipalTable b on a.RecipientEmail = b.UserEmail


select distinct a.* from @Aggregation a 
join @Aggregation b on 
a.PairHash = b.ReversePairHash
--where a.Sender = 'Anil Kalan'
where a.sender = @sender
order by a.PairID, a.senderID, a.RecipientID

select * from @Aggregation a 
where a.sender = @sender
order by senderID

GO
/****** Object:  StoredProcedure [dbo].[SeadAggregateSentMailOnFullName]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--select * from  SentMailSingleRecipients s 
--where UserFullName in ( 'Max Heera','Rene Sparks')
--and ToFullName in ('Max Heera','Rene Sparks')
--go


CREATE proc [dbo].[SeadAggregateSentMailOnFullName]
@sender varchar(2000)=null, @recipient varchar(2000)=null, @maxRecipientcount int = 1000, @debug varchar(1)='n'
as

--select * from vwFirstLastSentMail order by UserEmail

if @debug ='y'
begin
select 33,* from vwFirstLastSentMail where UserFullName in ( 'Max Heera','Rene Sparks')
order by UserFullName

select 36,* from SentMailSingleRecipients where UserFullName in ( 'Max Heera','Rene Sparks')
order by UserFullName

end

--select * from UserPrincipalTable where UserEmail like '%rene%'

--update UserPrincipalTable set AlternativeEmail2 = replace(AlternativeEmail,'sead.co.za','clisupport.co.za')

declare @Aggregation table 
(
PairID int,
SenderID int,
RecipientID int,
SenderFullName varchar(2000), RecipientFullName varchar(2000),
Sender varchar(2000),
Recipient varchar(2000),
PairHash varchar(2000),
ReversePairHash varchar(2000),
FromEmail varchar(2000),
SenderEmail varchar(2000), 
RecipientEmail varchar(2000), 
SenderNumberOfEmailsSent int, 
RecipientNumberOfEmailsSent int, 
TotalVolume int,
SenderFirstSentDate datetime,
SenderLastSentDate datetime,
RecipientFirstSentDate datetime,
RecipientLastSentDate datetime
)

 
 update s
 set ToFullName = u.DisplayName
 from  SentMailSingleRecipients s 
 join UserPrincipalTable u on u.AlternativeEmail2 = s.ToEmail
 where ToFullName is null

 --select * from SentMailSingleRecipients where UserFullName = ToFullName

insert into @Aggregation(PairHash,ReversePairHash,SenderFullName, RecipientFullName, SenderNumberOfEmailsSent)

select  UserFullName+'|'+ToFullName as PairHash, ToFullName+'|'+UserFullName as ReversePairHash, UserFullName, ToFullName, NumberOfEmailsSent
from (

select UserFullName, ToFullName,Count(*) NumberOfEmailsSent  from 
(
Select UserFullName, ToFullName
from SentMailSingleRecipients
where DateTimeSent > '1 May 2021'
and ToFullName is not null and RecipientCount <= @maxRecipientcount
--and 
--(
--	( UserFullName = case when @sender is not null then @sender else UserFullName end and ToFullName = case when @recipient is not null then @recipient else UserFullName end)
--or	( UserFullName = case when @recipient is not null then @recipient else UserFullName end and ToFullName = case when @sender is not null then @sender else UserFullName end)
--)
)f
group by UserFullName, ToFullName
)x
order by UserFullName, ToFullName


if @debug = 'y'
select distinct '90',UserFullName, ToFullName
from SentMailSingleRecipients
where DateTimeSent > '1 May 2021'
and ToFullName is not null and RecipientCount <= @maxRecipientcount
order by UserFullName, ToFullName
--and 
--(
--	( UserFullName = case when @sender is not null then @sender else UserFullName end and ToFullName = case when @recipient is not null then @recipient else UserFullName end)
--or	( UserFullName = case when @recipient is not null then @recipient else UserFullName end and ToFullName = case when @sender is not null then @sender else UserFullName end)
--)



--select * from SentMailSingleRecipients where toEmail like '%bandile.ndlazi@sead.co.za%'
 --update SentMailSingleRecipients set AlternativeToEmail = ToEmail where AlternativeToEmail is null

update a 
set SenderFirstSentDate = v.FirstSentDate, SenderLastSentDate = v.LastSentDate
from @Aggregation a
join vwFirstLastSentMail v on a.SenderFullName = v.UserFullName

update a 
set RecipientFirstSentDate = v.FirstSentDate, RecipientLastSentDate = v.LastSentDate
from @Aggregation a
join vwFirstLastSentMail v on a.RecipientFullName = v.UserFullName


--select 'a1',* from @aggregation

--find recipients that are senders
update recip
set recip.RecipientNumberOfEmailsSent = sender.SenderNumberOfEmailsSent
--select recip.RecipientEmail, sender.SenderEmail, * 
from  @Aggregation recip
join @Aggregation sender
on recip.RecipientFullName = sender.SenderFullName
and recip.SenderFullName = sender.RecipientFullName
where recip.RecipientFullName is not null and recip.SenderFullName is not null and
sender.SenderFullName is not null and sender.RecipientFullname is not null

if @debug = 'y'
select 'mm',* from @Aggregation


update @Aggregation set RecipientNumberOfEmailsSent = isnull(RecipientNumberOfEmailsSent,0)
update @Aggregation set TotalVolume = SenderNumberOfEmailsSent + RecipientNumberOfEmailsSent

update a
set SenderID = ID 
from @Aggregation  a
join UserPrincipalTable b on a.SenderFullName=b.DisplayName

update a
set RecipientID = ID 
from @Aggregation  a
join UserPrincipalTable b on a.RecipientFullName=b.DisplayName



declare @PairID int=1,@senderid int, @recipid int




declare fr cursor for select a.SenderID, a.RecipientID
from @Aggregation a join @Aggregation b on 
a.PairHash = b.ReversePairHash
order by a.senderID, a.RecipientID
open fr
fetch next from fr into @senderid, @recipid
while @@FETCH_STATUS=0
begin
	
	update @Aggregation set PairID = @PairID
	where SenderID = @senderid and RecipientID = @recipid
	and PairID is null

	update @Aggregation set PairID = @PairID
	where SenderID = @recipid and RecipientID = @senderid
	and PairID is null
	--increment pair id
	set @PairID = @PairID +1

	fetch next from fr into @senderid, @recipid
end
close fr
deallocate fr

declare @PairID2 int

declare fr cursor for select a.PairID, a.SenderID, a.RecipientID
from @Aggregation a join @Aggregation b on 
a.PairHash = b.ReversePairHash
where a.PairID is not null
order by a.senderID, a.RecipientID
open fr
fetch next from fr into @Pairid2, @senderid, @recipid
while @@FETCH_STATUS=0
begin
	
	--update @Aggregation set PairID = @PairID
	--where SenderID = @senderid and RecipientID = @recipid
	--and PairID is null

	update @Aggregation set PairID = @Pairid2
	where SenderID = @recipid and RecipientID = @senderid
	and PairID is null
	
	fetch next from fr into @Pairid2, @senderid, @recipid
end
close fr
deallocate fr


--select distinct 'debug' as marker,  PairID, SenderID, RecipientID, SenderFullName, RecipientFullName, FromEmail
--from @Aggregation a
--where a.SenderFullName = case when @sender is null then a.senderFullName else @sender end
--and a.RecipientFullName = case when @recipient is null then a.recipientFullName else @recipient end 
if @debug = 'y'
select '206',* from @Aggregation where SenderFullName in ('Max Heera','Rene Sparks')

select distinct a.* from @Aggregation a 
join @Aggregation b on 
a.PairHash = b.ReversePairHash
where a.SenderFullName = case when @sender is null then a.senderFullName else @sender end
and a.RecipientFullName = case when @recipient is null then a.recipientFullName else @recipient end 
order by a.PairID, a.senderID, a.RecipientID

select * from @Aggregation a 
where a.SenderFullName = case when @sender is null then a.senderFullName else @sender end
and a.RecipientFullName = case when @recipient is null then a.recipientFullName else @recipient end 
order by senderFullName, RecipientFullName



if @debug = 'y'
begin

select distinct 237, a.* from @Aggregation a 
join @Aggregation b on 
a.PairHash = b.ReversePairHash
where a.SenderFullName = case when @sender is null then a.senderFullName else @sender end
and a.RecipientFullName = case when @recipient is null then a.recipientFullName else @recipient end 
and a.SenderFullName in ('Max Heera','Rene Sparks') and a.RecipientFullName in ('Max Heera','Rene Sparks')
order by a.PairID, a.senderID, a.RecipientID

select 244, * from @Aggregation a 
where a.SenderFullName = case when @sender is null then a.senderFullName else @sender end
and a.RecipientFullName = case when @recipient is null then a.recipientFullName else @recipient end 
and SenderFullName in ('Max Heera','Rene Sparks') and RecipientFullName in ('Max Heera','Rene Sparks')
order by senderFullName, RecipientFullName

end
GO
/****** Object:  StoredProcedure [dbo].[SeadSentMailAggregation1]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SeadSentMailAggregation1]
as
--select * from SentEmail where RecipientCount = 0

select * from SentEmail where RecipientCount = 1

--select * from SentEmail where RecipientCount > 1

GO
/****** Object:  StoredProcedure [dbo].[SeadSplitMultipleRecipients]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SeadSplitMultipleRecipients]
as

DECLARE @NewRecords TABLE (ID int identity(100000, 1) primary key, UserEmail VARCHAR(2000), ToEmail VARCHAR(2000), Subject VARCHAR(2000), DateTimeSent DATETIME, ParentID int)

DECLARE @UserEmail VARCHAR(2000), @ToEmail VARCHAR(2000), @Subject VARCHAR(2000), @DateTimeSent DATETIME, @ParentID int

declare cr cursor for
select UserEmail, ToEmail, Subject, DateTimeSent, ID from SentEmail where RecipientCount > 1
open cr
fetch next from cr into @UserEmail, @ToEmail, @Subject, @DateTimeSent, @ParentID
while @@FETCH_STATUS=0
begin

	insert into @NewRecords(UserEmail, ToEmail, Subject, DateTimeSent, ParentID)
	select @UserEmail, Item, @Subject, @DateTimeSent, @ParentID from dbo.SplitStrings_CTE(@ToEmail,';')

fetch next from cr into @UserEmail, @ToEmail, @Subject, @DateTimeSent, @ParentID
end
close cr
deallocate cr

select * from @NewRecords order by ID

GO
/****** Object:  StoredProcedure [dbo].[SeadSplitMultipleRecipientsAnil]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SeadSplitMultipleRecipientsAnil]
as

DECLARE @NewRecords TABLE (ID int identity(100000, 1) primary key, UserEmail VARCHAR(2000), ToEmail VARCHAR(2000), Subject VARCHAR(2000), DateTimeSent DATETIME, ParentID int)

DECLARE @UserEmail VARCHAR(2000), @ToEmail VARCHAR(2000), @Subject VARCHAR(2000), @DateTimeSent DATETIME, @ParentID int

declare cr cursor for
select UserEmail, ToEmail, Subject, DateTimeSent, ID from AnilSenteMail2 where RecipientCount > 1
open cr
fetch next from cr into @UserEmail, @ToEmail, @Subject, @DateTimeSent, @ParentID
while @@FETCH_STATUS=0
begin

	insert into @NewRecords(UserEmail, ToEmail, Subject, DateTimeSent, ParentID)
	select @UserEmail, Item, @Subject, @DateTimeSent, @ParentID from dbo.SplitStrings_CTE(@ToEmail,';')

fetch next from cr into @UserEmail, @ToEmail, @Subject, @DateTimeSent, @ParentID
end
close cr
deallocate cr

select * from @NewRecords order by ID

GO
/****** Object:  StoredProcedure [dbo].[SeadSplitMultipleRecipientsOne]    Script Date: 2022/08/26 03:24:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SeadSplitMultipleRecipientsOne]
@TargetUserEmail varchar(2000)
as

DECLARE @NewRecords TABLE (ID int identity(100000, 1) primary key, UserEmail VARCHAR(2000), ToEmail VARCHAR(2000), Subject VARCHAR(2000), DateTimeSent DATETIME, ParentID int)

DECLARE @UserEmail VARCHAR(2000), @ToEmail VARCHAR(2000), @Subject VARCHAR(2000), @DateTimeSent DATETIME, @ParentID int

declare cr cursor for
select UserEmail, ToEmail, Subject, DateTimeSent, ID from AmandaSentEmail where RecipientCount > 1
open cr
fetch next from cr into @UserEmail, @ToEmail, @Subject, @DateTimeSent, @ParentID
while @@FETCH_STATUS=0
begin

	insert into @NewRecords(UserEmail, ToEmail, Subject, DateTimeSent, ParentID)
	select @UserEmail, Item, @Subject, @DateTimeSent, @ParentID from dbo.SplitStrings_CTE(@ToEmail,';')

fetch next from cr into @UserEmail, @ToEmail, @Subject, @DateTimeSent, @ParentID
end
close cr
deallocate cr

select * from @NewRecords order by ID

GO
USE [master]
GO
ALTER DATABASE [HuddleSmtp] SET  READ_WRITE 
GO
