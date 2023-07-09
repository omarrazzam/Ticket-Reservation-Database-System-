CREATE Database MyDB;
GO;
CREATE ROLE SystemAdmin;
GO;
CREATE ROLE SportsAssociationManager;
GO;
CREATE ROLE ClubRepresentative;
GO;
CREATE ROLE StadiumManager;
GO;
CREATE ROLE Fan;
GO;
Insert Into SystemUser Values ('Hanno', 'Frog');

Insert Into SystemAdmin Values ('Frog', 'Hanno');
Go;

CREATE VIEW clubInfo
AS
SELECT * FROM Club c where c.club_id = @cid

GO;

Create View upmatches as
select h.club_name as HostName , g.club_name as GuestClub, m.start_time as StartTime, m.end_time as EndTime 
from Match m Inner join Club h on (m.host_club_id = h.club_id) 
            inner join Club g on (m.guest_club_id = g.club_id)
where m.start_time >= CURRENT_TIMESTAMP;

Go;

Create View doneMatches as
select h.club_name as HostName , g.club_name as GuestClub, m.start_time as StartTime, m.end_time as EndTime 
from Match m Inner join Club h on (m.host_club_id = h.club_id) 
            inner join Club g on (m.guest_club_id = g.club_id)
where m.end_time < CURRENT_TIMESTAMP;
Go;


Create Function relatedclub (@crID int)
returns @t table (club_id int , Club_Name VARCHAR(20), Club_Location VARCHAR(20))
as
begin
    insert into @t
    select c.club_id,c.club_name,c.club_location
    from ClubRepresentative cr inner join Club c on (cr.club_id = c.club_id)
    where cr.cr_id = @crID;
return
end
Go;

GO;
CREATE PROC createAllTables 
AS
    CREATE TABLE SystemUser(
        u_username VARCHAR(20) PRIMARY KEY,
        u_password VARCHAR(20)
    );

    CREATE TABLE SystemAdmin(
        a_id int IDENTITY PRIMARY KEY,
        a_name VARCHAR(20),
        a_username VARCHAR(20),
        FOREIGN KEY (a_username) REFERENCES SystemUser (u_username) on delete cascade on update cascade
    );

    CREATE TABLE SportsAssociationManager(
        s_id int IDENTITY PRIMARY KEY,
        s_name VARCHAR(20),
        s_username VARCHAR(20),
        FOREIGN KEY (s_username) REFERENCES SystemUser (u_username) on delete cascade on update cascade
    );
    
     CREATE TABLE Club(
        club_id int IDENTITY PRIMARY KEY,
        club_name VARCHAR(20),
        club_location VARCHAR(20),
    );

    CREATE TABLE ClubRepresentative(
        cr_id int IDENTITY PRIMARY KEY,
        cr_name VARCHAR(20),
        club_id int,
        FOREIGN KEY (club_id) REFERENCES Club (club_id) on delete cascade on update cascade,
        cr_username VARCHAR(20),
        FOREIGN KEY (cr_username) REFERENCES SystemUser (u_username) on delete cascade on update cascade
    );

    CREATE TABLE Stadium(
        stad_id int IDENTITY PRIMARY KEY,
        stad_name VARCHAR(20),
        stad_location VARCHAR(20),
        capacity int,
        status BIT
    );
    
    CREATE TABLE StadiumManager(
        stadman_id int IDENTITY PRIMARY KEY,
        stadman_name VARCHAR(20),
        stad_id int,
        FOREIGN KEY (stad_id) REFERENCES Stadium (stad_id) on delete cascade on update cascade,
        stadman_username VARCHAR(20),
        FOREIGN KEY (stadman_username) REFERENCES SystemUser (u_username) on delete cascade on update cascade
    );

    CREATE TABLE Match(
        match_id int IDENTITY PRIMARY KEY,
        start_time datetime,
        end_time datetime,
        host_club_id int,
        FOREIGN KEY (host_club_id) REFERENCES Club (club_id),
        guest_club_id int,
        FOREIGN KEY (guest_club_id) REFERENCES Club (club_id),
        stadium_id int,
        FOREIGN KEY (stadium_id) REFERENCES Stadium (stad_id)
    );

    CREATE TABLE HostRequest(
        host_id int IDENTITY PRIMARY KEY,
        rep_id int,
        FOREIGN KEY (rep_id) REFERENCES ClubRepresentative (cr_id) on delete cascade on update cascade,
        man_id int,
        FOREIGN KEY (man_id) REFERENCES StadiumManager (stadman_id) ,
        match_id int,
        FOREIGN KEY (match_id) REFERENCES Match (match_id) ,
        
        status VARCHAR(20)
    );

    CREATE TABLE Fan(
        national_id int PRIMARY KEY,
        name varchar(20),
        birthdate DATETIME,
        address VARCHAR(20),
        phone_no int,
        status BIT,
        f_username VARCHAR(20),
        FOREIGN KEY (f_username) REFERENCES SystemUser (u_username) on delete cascade on update cascade

    );

    CREATE TABLE Ticket(
       ticket_id int IDENTITY PRIMARY KEY,
       ticket_status BIT,
       match_id int,
       FOREIGN KEY (match_id) REFERENCES Match (match_id) on delete cascade on update cascade
    );

    CREATE TABLE TicketBuyingTransaction(    
       fan_nationalID int,
       ticket_id int,
       FOREIGN KEY (fan_nationalID) REFERENCES fan (national_id) on delete cascade on update cascade,
       FOREIGN KEY (ticket_id) REFERENCES Ticket (ticket_id) on delete cascade on update cascade
    );
GO;


CREATE PROC dropAllTables
AS
    DROP TABLE TicketBuyingTransaction;
    DROP TABLE Ticket;
    DROP TABLE Fan;
    DROP TABLE HostRequest;
    DROP TABLE Match;
    DROP TABLE StadiumManager;
    DROP TABLE Stadium;
    DROP TABLE ClubRepresentative;
    DROP TABLE Club;
    DROP TABLE SportsAssociationManager;
    DROP TABLE SystemAdmin;
    DROP TABLE SystemUser;
GO;

CREATE PROC dropAllProceduresFunctionsViews
AS
    DROP PROC createAllTables;
    DROP PROC dropAllTables;
    DROP PROC clearAllTables;
    DROP VIEW allAssocManagers; 
    DROP VIEW allClubRepresentatives;
    DROP VIEW allStadiumManagers;
    DROP VIEW allFans;
    DROP VIEW allMatches; 
    DROP VIEW allTickets;
    DROP VIEW allCLubs;
    DROP VIEW allStadiums;
    DROP VIEW allRequests;
    DROP PROC addAssociationManager;
    DROP PROC addNewMatch;
    DROP VIEW clubsWithNoMatches;
    DROP PROC deleteMatch;
    DROP PROC deleteMatchesOnStadium;
    DROP PROC addClub;
    DROP PROC addTicket;
    DROP PROC deleteClub;
    DROP PROC addStadium;
    DROP PROC deleteStadium;
    DROP PROC blockFan;
    DROP PROC unblockFan;
    DROP PROC addRepresentative;
    DROP FUNCTION viewAvailableStadiumsOn;
    DROP PROC addHostRequest;
    DROP FUNCTION allUnassignedMatches;
    DROP PROC addStadiumManager;
    DROP FUNCTION allPendingRequests;
    DROP PROC acceptRequest;
    DROP PROC rejectRequest;
    DROP PROC addFan;
    DROP FUNCTION upcomingMatchesOfClub;
    DROP FUNCTION availableMatchesToAttend;
    DROP PROC purchaseTicket;
    DROP PROC updateMatchHost;
    DROP VIEW matchesPerTeam;
    DROP VIEW clubsNeverMatched;
    DROP FUNCTION clubsNeverPlayed;
    DROP FUNCTION matchWithHighestAttendance;
    DROP FUNCTION matchesRankedByAttendance; 
    DROP FUNCTION requestsFromClub;
GO;

go;
CREATE PROC clearAllTables
AS
   EXEC dropAllTables;
   EXEC createAllTables;
GO;

-- 2.2

CREATE VIEW allAssocManagers AS
SELECT u.u_username AS UserName, u.u_password AS Password, a.s_name AS Name
FROM SystemUser u inner JOIN SportsAssociationManager a on (u.u_username = a.s_username);

GO;

CREATE VIEW allClubRepresentatives AS
SELECT u.u_username AS UserName, u.u_password AS Password, a.cr_name AS ClubRepresentativeName, c.club_name AS ClubName
FROM SystemUser u inner JOIN ClubRepresentative a on (u.u_username = a.cr_username)
    INNER JOIN club c on (a.club_id = c.club_id);

GO;

CREATE VIEW allStadiumManagers AS
SELECT u.u_username AS UserName, u.u_password AS Password, a.stadman_name AS StadiumManagerName, c.stad_name AS StadiumName
FROM SystemUser u inner JOIN StadiumManager a on (u.u_username = a.stadman_username)
    INNER JOIN Stadium c on (a.stad_id = c.stad_id);

GO;

CREATE VIEW allFans AS
SELECT u.u_username AS UserName, u.u_password AS Password, a.name AS FanName, a.national_id AS NationalID, a.birthdate AS BirthDate, a.status AS Blocked
FROM SystemUser u inner JOIN Fan a on (u.u_username = a.f_username);

GO;

CREATE VIEW allMatches AS
SELECT h.club_name AS HostClubName, g.club_name AS GuestClubName, a.start_time AS StartTime
FROM Match a inner JOIN Club h on (a.host_club_id = h.club_id) INNER JOIN club g on (a.guest_club_id = g.club_id);

GO;

CREATE VIEW allTickets AS
SELECT c1.club_name AS HostClubName, c2.club_name AS GuestClubName, s.stad_name AS StadiumName, m.start_time AS StartTime
FROM Ticket t INNER JOIN Match m ON (t.match_id=m.match_id) 
              INNER JOIN Club c1 ON (m.host_club_id = c1.club_id)
              INNER JOIN Club c2 ON (m.guest_club_id = c2.club_id)
              INNER JOIN Stadium s ON (m.stadium_id = s.stad_id)

GO;


Create View allCLubs AS
SELECT c.club_name AS ClubName, c.club_location AS Location 
From Club c;

GO;

Create View allStadiums AS
SELECT stad_name AS StadiumName,stad_location AS Location,capacity AS Capacity,status AS Status From Stadium;

GO;

Create View allRequests AS
SELECT c.cr_name AS ClubRepresentativeName,m.stadman_name AS StadiumManagerName,status AS Status
FROM ClubRepresentative c INNER JOIN HostRequest h on (c.cr_id = h.rep_id)
INNER JOIN StadiumManager m on (h.man_id = m.stadman_id);
 
GO;



CREATE PROC addAssociationManager 
@name varchar(20),
@userName varchar(20),
@password varchar(20)
AS
    if not exists (select * from SystemUser where @userName = SystemUser.u_username)
        insert into SystemUser values (@userName,@password);
     if not exists (select * from SportsAssociationManager where @userName = SportsAssociationManager.s_username)
    insert into SportsAssociationManager values (@name,@userName);
GO;

CREATE PROC addNewMatch 
@hostname varchar(20),
@guestname varchar(20),
@starttime datetime,
@endtime datetime
AS
    insert into Match values (@starttime,@endtime,(select club_id
                                                   from club
                                                   where club.club_name = @hostname), (select club_id
                                                                                       from club
                                                                                       where club.club_name = @guestname), NULL);
GO;

CREATE VIEW clubsWithNoMatches as
SELECT c1.club_name AS ClubName
FROM Club as c1 
where NOT Exists ((select m1.host_club_id
                  from Match m1
                  where m1.host_club_id = c1.club_id)
            UNION

                 (select m2.guest_club_id
                 from Match m2
                 where m2.guest_club_id = c1.club_id))
GO;



CREATE PROC deleteMatch
@hostname varchar(20),
@guestname varchar(20),
@starttime datetime,
@endtime datetime
AS
 DECLARE @matchId as int = (select m.match_id 
                            from Match m inner join Club c1 on (c1.club_id = m.host_club_id) inner join club c2 on (c2.club_id = m.guest_club_id)
                            where c1.club_name = @hostname AND c2.club_name = @guestname AND m.start_time = @starttime AND m.end_time = @endtime);
    DELETE FROM HostRequest WHERE HostRequest.match_id = @matchId;
    DELETE FROM Ticket WHERE Ticket.match_id = @matchId;
    DELETE FROM Match where Match.match_id = @matchId;

Go;

CREATE PROC deleteMatchesOnStadium
@stad_name varchar(20)
AS  
    DECLARE @matchId as int = (select m.match_id 
                            from Match m inner join Stadium s ON (s.stad_id = m.stadium_id)
                            where S.stad_name = @stad_name AND m.start_time > CURRENT_TIMESTAMP);

    DELETE FROM HostRequest WHERE HostRequest.match_id = @matchId;
    DELETE FROM Ticket WHERE Ticket.match_id = @matchId;

    DELETE FROM Match where match.match_id = @matchId;
GO;

CREATE PROC addClub
@club_name varchar(20),
@club_location varchar(20)
AS
    INSERT into Club values (@club_name,@club_location);
GO;

CREATE PROC addTicket
@hostname varchar(20),
@guestname varchar(20),
@starttime datetime
AS
    INSERT INTO Ticket values (1,(select top 1 match_id
                                  from Match 
                                  where (match.host_club_id = (select club_id 
                                                               from club 
                                                               where club.club_name = @hostname and match.start_time = @starttime) and match.guest_club_id = (select club_id
                                                                                                                            from club
                                                                                                                            where club.club_name = @guestname))));

GO;

CREATE PROC deleteClub 
@clubname varchar(20)
AS
    declare @clubid as int  = (select  club_id 
                               from club 
                               where club.club_name = @clubname);

    DECLARE @matchid as table (matchid int)
                          insert into @matchid
                          select m.match_id 
                              from Match m
                              where m.host_club_id = @clubid or m.guest_club_id = @clubid;


    DELETE FROM HostRequest where match_id in (select matchid from @matchid);

    DELETE FROM ClubRepresentative WHERE club_id = @clubid;



    DELETE FROM Match where match.host_club_id IN (select C.club_id 
                                                  from club C
                                                  where c.club_name = @clubname)

    DELETE FROM Match where match.guest_club_id IN (select club_id 
                                                    from club 
                                                    where club.club_name = @clubname)

    DELETE From club where club.club_name = @clubname;

GO;

CREATE PROC addStadium
@stadname varchar(20),
@stadlocation varchar(20),
@capacity int
AS
    INSERT INTO Stadium values (@stadname, @stadlocation, @capacity, 1)
GO;

CREATE PROC deleteStadium
@stadname varchar(20)
AS
    declare @stadId as int = (Select stad_id
                              from Stadium
                              where Stadium.stad_name = @stadname);

     DECLARE @matchid as table (matchid int)
                          insert into @matchid
                          select m.match_id 
                              from Match m
                              where m.stadium_id = @stadId;
    
    Delete from HostRequest where HostRequest.match_id in (select matchid from @matchid);
    delete from Match where match.stadium_id = @stadId;
    delete from StadiumManager where StadiumManager.stad_id = @stadId;
    Delete from stadium where stadium.stad_name = @stadname
GO;

CREATE PROC blockFan
@nationalid int
AS 
Update fan
set status = 0 
WHERE fan.national_id = @nationalid;

GO;

CREATE PROC unblockFan
@nationalid int
AS 
Update fan
set status = 1 
WHERE fan.national_id = @nationalid;

GO;

CREATE PROC addRepresentative
@name varchar(20),
@clubname varchar(20),
@username varchar(20),
@password varchar(20)
AS 
    if not exists (select * from SystemUser where @userName = SystemUser.u_username)
        insert into SystemUser Values (@username,@password);

    if not exists (select * from ClubRepresentative where @userName = ClubRepresentative.cr_username)
        insert into ClubRepresentative values (@name, (select club_id 
                                                           from club
                                                           where club_name = @clubname), @username);

GO;

CREATE FUNCTION viewAvailableStadiumsOn (@time datetime)
Returns @t table (sname varchar(20), slocation varchar(20), scapacity int )
as
begin
    insert into @t 
    select stad_name,stad_location,capacity
    from stadium s LEFT OUTER JOIN MATCH m ON (s.stad_id = m.stadium_id)
    where (m.start_time <> @time or m.start_time is null) and s.status = 1
    group by stad_name,stad_location,capacity;
return 
end
GO;


CREATE proc addHostRequest
@clubID INT,
@stadname VARCHAR(20),
@starttime datetime
AS
    INSERT INTO HostRequest VALUES ((SELECT c.cr_id
                                     FROM ClubRepresentative c INNER JOIN Club k ON (k.club_id = c.club_id)
                                     WHERE k.club_id = @clubID), (SELECT a.stadman_id
                                                                    FROM Stadium s INNER JOIN StadiumManager a ON (s.stad_id = a.stad_id)
                                                                    WHERE s.stad_name = @stadname ), (SELECT m.match_id
                                                                                                            FROM Match m INNER JOIN Club c ON (m.host_club_id = c.club_id) 
                                                                                                                       left outer JOIN Stadium s ON (m.stadium_id = s.stad_id)
                                                                                                            WHERE m.start_time = @starttime and m.host_club_id = @clubID), 'unhandled');






GO;

CREATE FUNCTION allUnassignedMatches (@clubname varchar(20))
Returns @t table (guestName varchar(20), startTime datetime)
as
begin
    insert into @t 
    select (SELECT c1.club_name FROM Club c1 WHERE c1.club_id = C.club_id) AS GuestName, m.start_time AS StartTime
    from match m INNER JOIN Club C ON (m.host_club_id = c.club_id)
    where m.stadium_id IS NULL;
return 
end
GO;

CREATE PROC addStadiumManager
@name varchar(20),
@stadname varchar(20),
@username varchar(20),
@password varchar(20)
AS 
    if not exists (select * from SystemUser where @userName = SystemUser.u_username)
        insert into SystemUser Values (@username,@password);

    if not exists (select * from StadiumManager where @userName = StadiumManager.stadman_username)    
        insert into StadiumManager values (@name, (select s.stad_id 
                                                           from Stadium s
                                                           where s.stad_name = @stadname), @username);
GO;

CREATE FUNCTION allPendingRequests (@stadManID int)
Returns @t table (clubRepName varchar(20),hostclubName varchar(20), guestClubName varchar(20),starttime datetime, endttime datetime, status varchar(20))
as
begin

    insert into @t 
    SELECT cr.cr_name,c1.club_name, c.club_name,m.start_time,m.end_time, h.status
    FROM StadiumManager s INNER JOIN HostRequest h ON (h.man_id = @stadmanID) 
                        INNER JOIN ClubRepresentative cr ON (h.rep_id = cr.cr_id)
                        INNER JOIN Match m ON (h.match_id = m.match_id)
                        INNER JOIN Club c ON (m.guest_club_id = c.club_id)
                        INNER JOIN Club c1 ON (m.host_club_id = c1.club_id)
    group by cr.cr_name,c1.club_name, c.club_name,m.start_time,m.end_time, h.status
return 
end
GO;

CREATE PROC acceptRequest
@stadmanusername varchar(20),
@hostingclubname varchar(20),
@guestclubname varchar(20),
@starttime datetime
AS 

    declare @stadmanID as int  = (select  s.stadman_id 
                                  from StadiumManager s 
                                  where s.stadman_username = @stadmanusername);

    declare @hostclubID as int  = (select  c.club_id 
                                  from Club c 
                                  where c.club_name = @hostingclubname);

    declare @guestclubID as int  = (select  c.club_id 
                                  from Club c 
                                  where c.club_name = @guestclubname);

    declare @stadID as int = (SELECT s.stad_id
                              FROM Stadium s inner join StadiumManager sm on (s.stad_id = sm.stad_id)
                              WHERE sm.stadman_username = @stadmanusername );

    declare @matchID as int = (SELECT m.match_id
                              FROM match m
                              WHERE m.host_club_id = @hostclubID and m.guest_club_id = @guestclubID and m.start_time = @starttime );

    declare @hostID as int = (SELECT h.host_id
                              FROM HostRequest h
                              WHERE h.match_id = @matchID and h.man_id = @stadmanID ) 


    Update HostRequest
    set status= 'accepted' 
    WHERE host_id = @hostID and status = 'unhandled'

    Update Match
    set stadium_id = @stadID
    where match_id = @matchID;

    Declare @i int = 0;
    declare @capacity int = (select s.capacity from stadium s where s.stad_id = @stadID)
        while @i < (@capacity)
        begin
            exec addticket @hostname = @hostingclubname, @guestname =@guestclubname, @starttime = @starttime;
            set @i = @i+1;
            END;

GO;


CREATE PROC rejectRequest
@stadmanusername varchar(20),
@hostingclubname varchar(20),
@guestclubname varchar(20),
@starttime datetime
AS 

    declare @stadmanID as int  = (select  s.stadman_id 
                                  from StadiumManager s 
                                  where s.stadman_username = @stadmanusername);

    declare @hostclubID as int  = (select  c.club_id 
                                  from Club c 
                                  where c.club_name = @hostingclubname);

    declare @guestclubID as int  = (select  c.club_id 
                                  from Club c 
                                  where c.club_name = @guestclubname);

    declare @matchID as int = (SELECT m.match_id
                              FROM match m
                              WHERE m.host_club_id = @hostclubID and m.guest_club_id = @guestclubID and m.start_time = @starttime );

    declare @hostID as int = (SELECT h.host_id
                              FROM HostRequest h
                              WHERE h.match_id = @matchID and h.man_id = @stadmanID ) 


    Update HostRequest
    set status= 'rejected' 
    WHERE host_id = @hostID and status = 'unhandled'
GO;

CREATE PROC addFan
@name varchar(20),
@nationalID varchar(20),
@username varchar(20),
@password varchar(20),
@birthdate datetime,
@address varchar(20),
@phonenumber int
AS 
    if not exists (select * from SystemUser where @userName = SystemUser.u_username)
        insert into SystemUser Values (@username,@password);
    
    if not exists (select * from Fan where @userName = Fan.f_username)
        insert into Fan values (@nationalID,@name,@birthdate,@address,@phonenumber,1,@username);
GO;

CREATE FUNCTION upcomingMatchesOfClub (@clubID int)
Returns @t table (Host varchar(20), Guest varchar(20),startTime datetime,endtime datetime, stadname varchar(20))
as
begiN
    insert into @t 

    SELECT c1.club_name, c2.club_name, m.start_time,m.end_time , s.stad_name
    FROM Club c1 INNER JOIN Match m ON (m.host_club_id = c1.club_id )
                 INNER JOIN Club c2 ON (m.guest_club_id = c2.club_id )
                 LEFT OUTER JOIN Stadium s ON (m.stadium_id = s.stad_id)
    WHERE m.start_time > CURRENT_TIMESTAMP and m.host_club_id = @clubID and c1.club_id = @clubID

UNION

    SELECT c1.club_name ,c2.club_name, m.start_time,m.end_time, s.stad_name
    FROM Club c1 INNER JOIN Match m ON (m.host_club_id = c1.club_id )
                 INNER JOIN Club c2 ON (m.guest_club_id = c2.club_id )
                 LEFT OUTER JOIN Stadium s ON (m.stadium_id = s.stad_id)
    WHERE m.start_time > CURRENT_TIMESTAMP and m.guest_club_id = @clubID and c2.club_id = @clubID

return 
end
GO;

CREATE FUNCTION availableMatchesToAttend (@TIME DATETIME)
Returns @t table (hostclub varchar(20), guestClub varchar(20),starttime datetime, stadname varchar(20))
as
begin
   insert into @t 
   SELECT h.club_name, g.club_name,m.start_time,s.stad_name
   FROM Match m INNER JOIN Club h ON (m.host_club_id = h.club_id) 
                INNER JOIN Club g ON (m.guest_club_id = g.club_id)
                INNER JOIN Stadium s ON (S.stad_id = m.stadium_id)
   WHERE m.start_time >= @TIME AND EXISTS (SELECT ticket_id
                                              FROM MATCH M2 INNER JOIN Ticket t ON (M2.match_id = t.match_id)
                                              WHERE M.match_id = M2.match_id AND t.ticket_status = 1)
return 
end
GO;

CREATE PROC purchaseTicket
@nationalID varchar(20),
@hostname varchar(20),
@guestname varchar(20),
@starttime datetime
AS 
    DECLARE @ticketid as int =( SELECT TOP 1 Ticket.ticket_id 
                     FROM Ticket 
                     WHERE ticket_status = 1 AND Ticket.match_id = (SELECT m.match_id 
                     FROM Match m INNER JOIN Club h ON (m.host_club_id = h.club_id) 
                     INNER JOIN Club g ON (m.guest_club_id = g.club_id)
                     WHERE m.start_time = @starttime AND h.club_name = @hostname 
                     AND g.club_name = @guestname));
   DECLARE @fanid as int = (SELECT  f.national_id
                            FROM Fan f
                            WHERE f.national_id = @nationalID  AND f.status = 1);
    if exists(SELECT  f.national_id FROM Fan f WHERE f.national_id = @nationalID  AND f.status = 1)
        insert into TicketBuyingTransaction Values (@fanid,@ticketid);
     if exists(SELECT  f.national_id FROM Fan f WHERE f.national_id = @nationalID  AND f.status = 1)
        Update Ticket
        set ticket_status=0 
        WHERE Ticket.ticket_id = @ticketid;
GO;

CREATE PROC updateMatchHost
@hostclubname varchar(20),
@guestclubname varchar(20),
@starttime datetime
AS 
    Update Match
    set host_club_id = (Select c.club_id from club c where c.club_name = @guestclubname), guest_club_id = (Select g.club_id from club g where g.club_name = @hostclubname) , stadium_id = null
    WHERE start_time = @starttime AND match.host_club_id = (Select h.club_id from club h where h.club_name = @hostclubname)
                                  AND match.guest_club_id = (Select f.club_id from club f where f.club_name = @guestclubname);
GO;

CREATE VIEW matchesPerTeam As 
SELECT Distinct f.club_name, SUM(counter) as CountMatches
From ( select h.club_name, COUNT(m.match_id) as counter
        from match m Right outer Join Club h on (h.club_id = m.host_club_id)
        group by club_name
        UNION
        select g.club_name, COUNT(m.match_id) as counter
        from match m Right outer Join Club g on (g.club_id = m.guest_club_id)
        group by club_name) as f
GROUP BY f.club_name
GO;

CREATE VIEW clubsNeverMatched AS
SELECT c1.Club_name as club1, c2.Club_name as club2
From Club c1,Club c2
where  c1.club_id > c2.club_id AND NOT Exists (Select * from match m
                                                        where (m.guest_club_id = c1.club_id and m.host_club_id = c2.club_id) or (m.guest_club_id = c2.club_id and m.host_club_id = c1.club_id));
GO;

CREATE FUNCTION clubsNeverPlayed (@clubname varchar(20))
Returns @t table (clubname varchar(20))
as
begin
     insert into @t 
     SELECT c2.Club_name
     From Club c1,Club c2
     where  c1.club_id > c2.club_id and c1.club_name = @clubname AND NOT Exists (Select * from match m
                                                    where (m.guest_club_id = c1.club_id and m.host_club_id = c2.club_id) or (m.guest_club_id = c2.club_id and m.host_club_id = c1.club_id));
return 
end
GO;

CREATE FUNCTION matchWithHighestAttendance ()
Returns @t table (hostname varchar(20), guestname varchar(20))
as
begin  
     insert into @t
     select  top 1 c1.club_name, c2.club_name
     From Club c1 Inner Join Match m on c1.club_id = m.host_club_id INNER JOIN Club c2 on c2.club_id = m.guest_club_id
     where Exists  (select top 1 t.match_id, count(t.ticket_id) as cout
            from Ticket t 
            where t.ticket_status = 0
            group BY t.match_id 
            order by cout desc);
return 
end
GO;

CREATE FUNCTION matchesRankedByAttendance ()
Returns @t table (hostname varchar(20), guestname varchar(20))
as
begin  
     insert into @t
     select top 10000 c1.club_name, c2.club_name
     From Club c1 Inner Join Match m on (c1.club_id = m.host_club_id) INNER JOIN Club c2 on (c2.club_id = m.guest_club_id) left outer join (select t.match_id, count(t.ticket_id) as cout
                                                                                                                                       from Ticket t 
                                                                                                                                       where t.ticket_status = 0
                                                                                                                                       group BY t.match_id ) as t1 on (t1.match_id = m.match_id)
     where m.end_time < CURRENT_TIMESTAMP
     order by t1.cout desc;
return 
end
GO;

CREATE FUNCTION requestsFromClub (@stadname varchar(20),@clubname varchar(20))
Returns @t table (hostname varchar(20), guestname varchar(20))
as
begin  
    insert into @t
     SELECT c1.club_name, c2.club_name
     FROM HostRequest as hs right outer join match m on (hs.match_id = m.match_id)
                                             left outer join stadium s on (m.stadium_id = s.stad_id)
                                            inner join club c1 on (m.host_club_id = c1.club_id)
                                            inner join club c2 on (m.guest_club_id = c2.club_id)
                                             inner join (select cr.cr_id
                                                         from clubRepresentative cr inner join club c3 on (cr.club_id = c3.club_id) 
                                                         where c3.club_name = @clubname) as clubrepdone on (clubrepdone.cr_id = hs.rep_id)

     WHERE s.stad_name = @stadname or s.stad_name is null;
return 
end
GO;

CREATE PROC CheckUser
@username varchar(20),
@password varchar(20),
@outbit INT output
AS 

	if not exists (select * from SystemUser where @userName = SystemUser.u_username AND @password = SystemUser.u_password)
        set @outbit = 0;
	else
		if exists (select * from SystemAdmin where @userName = SystemAdmin.a_username)
		set @outbit = 1;
	else 
		if exists (select * from SportsAssociationManager where @userName = SportsAssociationManager.s_username)
		set @outbit = 2;
	else 
		if exists (select * from ClubRepresentative where @userName = ClubRepresentative.cr_username)
		set @outbit = 3;
	else 
		if exists (select * from StadiumManager where @userName = StadiumManager.stadman_username)
		set @outbit = 4;
	else 
		if exists (select * from Fan where @userName = Fan.f_username)
		set @outbit = 5;
Go;



CREATE Function allMatchesWithTickets (@starttime datetime)
Returns @t table (HostClub varchar(20), GuestClub varchar(20),StadiumName varchar(20),StadiumLocation varchar(20))
AS
Begin
insert into @t
    Select h.club_name As HostClub,g.club_name AS GuestClub,s.stad_name As StadiumName,s.stad_location AS StadiumLocation
    From Match m inner join Ticket t on (m.match_id = t.match_id) Inner join 
    club h on (m.host_club_id = h.club_id) Inner Join
    club g on (m.guest_club_id = g.club_id) Inner Join
    Stadium s on (s.stad_id = m.stadium_id)
    where t.ticket_status = 1 AND m.start_time >= @starttime
    Group BY h.club_name,g.club_name,s.stad_name,s.stad_location;

return 
end
GO;

