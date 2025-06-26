CREATE OR ALTER PROCEDURE AllocateSubjects
AS
BEGIN
    DECLARE @StudentId INT, @Preference INT, @SubjectId VARCHAR(10), @SubjectFound BIT

    -- Cursor to loop over students in descending order of GPA
    DECLARE student_cursor CURSOR FOR
        SELECT StudentId FROM StudentDetails ORDER BY GPA DESC;

    OPEN student_cursor;
    FETCH NEXT FROM student_cursor INTO @StudentId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Preference = 1;
        SET @SubjectFound = 0;

        WHILE @Preference <= 5 AND @SubjectFound = 0
        BEGIN
            -- Get subject based on current preference
            SELECT @SubjectId = SubjectId
            FROM StudentPreference
            WHERE StudentId = @StudentId AND Preference = @Preference;

            -- If seat available
            IF EXISTS (
                SELECT 1 FROM SubjectDetails
                WHERE SubjectId = @SubjectId AND RemainingSeats > 0
            )
            BEGIN
                INSERT INTO Allotments (SubjectId, StudentId)
                VALUES (@SubjectId, @StudentId);

                UPDATE SubjectDetails
                SET RemainingSeats = RemainingSeats - 1
                WHERE SubjectId = @SubjectId;

                SET @SubjectFound = 1;
            END

            SET @Preference = @Preference + 1;
        END

        -- Insert into UnallotedStudents if not allotted
        IF @SubjectFound = 0
        BEGIN
            IF NOT EXISTS (
                SELECT 1 FROM UnallotedStudents WHERE StudentId = @StudentId
            )
            BEGIN
                INSERT INTO UnallotedStudents (StudentId)
                VALUES (@StudentId);
            END
        END

        FETCH NEXT FROM student_cursor INTO @StudentId;
    END

    CLOSE student_cursor;
    DEALLOCATE student_cursor;
END;
