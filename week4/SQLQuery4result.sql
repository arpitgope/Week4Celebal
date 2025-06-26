-- View who got which subject
SELECT 
    a.StudentId, 
    s.StudentName, 
    a.SubjectId, 
    sd.SubjectName
FROM Allotments a
JOIN StudentDetails s ON a.StudentId = s.StudentId
JOIN SubjectDetails sd ON a.SubjectId = sd.SubjectId;

-- View students who did not get any subject
SELECT 
    u.StudentId,
    s.StudentName
FROM UnallotedStudents u
JOIN StudentDetails s ON u.StudentId = s.StudentId;
