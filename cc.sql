CREATE PROCEDURE r4
AS BEGIN

DECLARE @PR TABLE (
        paperID INTEGER,
        pageRank DECIMAL(20, 7),
        PRIMARY KEY (paperID)
);
DECLARE @tempPR TABLE (
        paperID INTEGER,
        pageRank DECIMAL(20, 7),
        PRIMARY KEY (paperID)
);

DECLARE @deltaPR TABLE (
        difID INTEGER,
        pageRankChange DECIMAL(20, 7),
        PRIMARY KEY (difID)
);

DECLARE @sinks TABLE (
        paperID INTEGER,
        PRIMARY KEY (paperID)
);

DECLARE @citations TABLE (
        paperID INTEGER,
        citationsCount INTEGER,
        PRIMARY KEY (paperID)
);


INSERT INTO @citations
SELECT n.paperID, COUNT(DISTINCT e.citedpaperID)
FROM nodes n LEFT OUTER JOIN edges e
ON n.paperID = e.paperID
GROUP BY n.paperID;

INSERT INTO @sinks
SELECT c.paperID
FROM @citations c
WHERE c.citationsCount = 0;

DECLARE @dif DECIMAL(20, 7);
SET @dif = 1;

DECLARE @d DECIMAL(20, 7);
SET @d = 0.85;

DECLARE @count DECIMAL(20, 7);
SET @count = (SELECT COUNT(*) FROM nodes);

DECLARE @totalSinkPR DECIMAL(20, 7);

INSERT INTO @deltaPR 
SELECT n.paperID, 0
FROM nodes n;

INSERT INTO @PR
SELECT n.paperID, pageRank = 1 / @count
FROM nodes n;


WHILE (@dif > 0.01) BEGIN
        SET @totalSinkPR = (SELECT SUM(pr.pageRank)
        FROM @sinks s INNER JOIN @PR pr ON s.paperID = pr.paperID);

        INSERT INTO @tempPR
        SELECT e.citedpaperID, pageRank = (1 - @d) / @count + SUM(@d * pr.pageRank / c.citationsCount) + @d * @totalSinkPR / (@count - 1)
        FROM @PR pr
        INNER JOIN edges e ON pr.paperID = e.paperID
        INNER JOIN @citations c ON pr.paperID = c.paperID
        GROUP BY e.citedpaperID;

        UPDATE @tempPR
        SET pageRank = temp.pageRank - @d * pr.pageRank / (@count - 1)
        FROM @tempPR temp INNER JOIN @PR pr ON temp.paperID = pr.paperID
        WHERE pr.paperID IN (SELECT s.paperID FROM @sinks s);

        UPDATE @deltaPR
        SET pageRankChange = temp.pageRank - pr.pageRank
        FROM @PR pr 
        INNER JOIN @tempPR temp ON pr.paperID = temp.paperID
        WHERE difId = pr.paperID;

        DELETE FROM @PR;
        INSERT INTO @PR
        SELECT * FROM @tempPR;
        DELETE FROM @tempPR;

        SET @dif = (SELECT SUM(d.pageRankChange) FROM @deltaPR d);
END

SELECT TOP(10) pr.paperID, n.paperTitle, pr.pageRank
FROM @PR pr INNER JOIN nodes n ON pr.paperID = n.paperID
ORDER BY pr.pageRank DESC;

END;     

GO

EXECUTE r4;

GO

DROP PROCEDURE r4;

GO

