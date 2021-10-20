CREATE PROCEDURE getCCo1
AS BEGIN
DECLARE @visited TABLE (
        paperID INTEGER,
        PRIMARY KEY (paperID)
);
DECLARE @myComp TABLE (
        paperID INTEGER
        PRIMARY KEY (paperID)
);
DECLARE @prevSize INTEGER;
DECLARE @curSize INTEGER;
DECLARE @nodeCount INTEGER;
SET @nodeCount = (SELECT COUNT(*) FROM nodes);
DECLARE @visitedCount INTEGER;
SET @visitedCount = 0;
WHILE (@nodeCount > @visitedCount) BEGIN
        INSERT INTO @myComp 
        SELECT TOP(1) n.paperID
        FROM nodes n
        WHERE n.paperID NOT IN (SELECT v.paperId FROM @visited v)
        ORDER BY NEWID();
        SET @prevSize = 0;
        SET @curSize = 1;
        WHILE (@curSize > @prevSize) BEGIN
                INSERT INTO @myComp 
                SELECT e.paperID
                FROM edges e
                WHERE e.citedPaperID IN (SELECT c.paperID FROM @myComp c) AND e.paperID NOT IN (SELECT c.paperID FROM @myComp c)
                UNION 
                SELECT e.citedPaperID
                FROM edges e
                WHERE e.paperID IN (SELECT c.paperID FROM @myComp c) AND e.citedPaperID NOT IN (SELECT c.paperID FROM @myComp c);
                SET @prevSize= @curSize;
                SET @curSize= (SELECT COUNT(*) FROM @myComp);
        END
        
        INSERT INTO @visited
        SELECT c.paperID
        FROM @myComp c
        WHERE c.paperID NOT IN (SELECT v.paperID FROM @visited v);
        IF (@curSize > 4 AND @curSize < 11) BEGIN
                SELECT n.paperID, n.paperTitle
                FROM nodes n
                WHERE n.paperID IN (
                        SELECT c.paperID
                        FROM @myComp c
                );
        END
        SET @visitedCount = (SELECT COUNT(*) FROM @visited);
        DELETE FROM @myComp
END
END;     
GO
EXECUTE getCCo1;
GO
DROP PROCEDURE getCCo1;
