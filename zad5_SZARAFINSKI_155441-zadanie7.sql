CREATE TABLE w_egzamin (
    id              NUMBER(11) NOT NULL,
    data            DATE NOT NULL,
    ocena           NUMBER(2,1) NOT NULL,
    nr_terminu      NUMBER(1),
    student_id      NUMBER(11) NOT NULL,
    przedmioty_id   NUMBER(11) NOT NULL
);

ALTER TABLE w_egzamin ADD CONSTRAINT egzamin_pk PRIMARY KEY ( id,przedmioty_id );

CREATE TABLE w_przedmioty (
    id             NUMBER(11) NOT NULL,
    nazwa          VARCHAR2(50) NOT NULL,
    ilosc_godzin   NUMBER(2) NOT NULL
);

ALTER TABLE w_przedmioty ADD CONSTRAINT przedmioty_pk PRIMARY KEY ( id );

CREATE TABLE w_student (
    id         NUMBER(11) NOT NULL,
    imie       VARCHAR2(30) NOT NULL,
    nazwisko   VARCHAR2(40) NOT NULL
);

ALTER TABLE w_student ADD CONSTRAINT student_pk PRIMARY KEY ( id );

ALTER TABLE w_egzamin ADD CONSTRAINT egzamin_przedmioty_fk FOREIGN KEY ( przedmioty_id )
    REFERENCES w_przedmioty ( id );

ALTER TABLE w_egzamin ADD CONSTRAINT egzamin_student_fk FOREIGN KEY ( student_id )
    REFERENCES w_student ( id );


CREATE SEQUENCE w_egzamin_id_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER w_egzamin_id_trg BEFORE
    INSERT ON w_egzamin
    FOR EACH ROW
    WHEN (
        new.id IS NULL
    )
BEGIN
    :new.id := w_egzamin_id_seq.nextval;
END;
/

CREATE SEQUENCE w_przedmioty_id_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER w_przedmioty_id_trg BEFORE
    INSERT ON w_przedmioty
    FOR EACH ROW
    WHEN (
        new.id IS NULL
    )
BEGIN
    :new.id := w_przedmioty_id_seq.nextval;
END;
/

CREATE SEQUENCE w_student_id_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER w_student_id_trg BEFORE
    INSERT ON w_student
    FOR EACH ROW
    WHEN (
        new.id IS NULL
    )
BEGIN
    :new.id := w_student_id_seq.nextval;
END;
/



INSERT INTO w_przedmioty(nazwa, ilosc_godzin)  VALUES ('Bazy Danych', '60');
INSERT INTO w_przedmioty(nazwa, ilosc_godzin)   VALUES ( 'Analiza Matematyczna', '45');
INSERT INTO w_przedmioty(nazwa, ilosc_godzin)   VALUES ('Rachunek Prawdopodobieñstwa', '30');

INSERT INTO w_student(imie, nazwisko) VALUES ('Jan', 'Kowalski');
INSERT INTO w_student(imie, nazwisko) VALUES ('Anna', 'Komar');
INSERT INTO w_student(imie, nazwisko) VALUES ('Jerzy', 'Nowak');
INSERT INTO w_student(imie, nazwisko) VALUES ('Sebastian', 'Rybnicki');

INSERT INTO w_egzamin( DATA, ocena, nr_terminu, student_id, przedmioty_id) VALUES ('14/11/03', 2, 1,1,3);
INSERT INTO w_egzamin( DATA, ocena, nr_terminu, student_id, przedmioty_id) VALUES ('14/11/03', 2, 1,2,3);
INSERT INTO w_egzamin( DATA, ocena, nr_terminu, student_id, przedmioty_id) VALUES ('14/11/03', 2, 1,3,3);
INSERT INTO w_egzamin( DATA, ocena, nr_terminu, student_id, przedmioty_id) VALUES ('14/11/04', 4, 1,1,1);
INSERT INTO w_egzamin( DATA, ocena, nr_terminu, student_id, przedmioty_id) VALUES ('14/11/03', 4.5, 1,2,1);
INSERT INTO w_egzamin( DATA, ocena, nr_terminu, student_id, przedmioty_id) VALUES ('14/11/03', 5, 1,4,1);
INSERT INTO w_egzamin( DATA, ocena, nr_terminu, student_id, przedmioty_id) VALUES ('14/11/11', 3,2,1,3);
INSERT INTO w_egzamin( DATA, ocena, nr_terminu, student_id, przedmioty_id) VALUES ('14/11/11', 2, 2,2,2);
INSERT INTO w_egzamin( DATA, ocena, nr_terminu, student_id, przedmioty_id) VALUES ('14/11/12', 2, 1,3,2);

CREATE TABLE w_warunek (
    id              NUMBER(11) NOT NULL,
    kwota           NUMBER(6,2) NOT NULL,
    student_id      NUMBER(11) NOT NULL,
    przedmioty_id   NUMBER(11) NOT NULL
);

ALTER TABLE w_warunek ADD CONSTRAINT warunek_pk PRIMARY KEY ( id );

ALTER TABLE w_warunek ADD CONSTRAINT warunek_przedmioty_fk FOREIGN KEY ( przedmioty_id )
    REFERENCES w_przedmioty ( id );

ALTER TABLE w_warunek ADD CONSTRAINT warunek_student_fk FOREIGN KEY ( student_id )
    REFERENCES w_student ( id );
    
CREATE SEQUENCE w_warunek_id_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER w_warunek_id_trg BEFORE
    INSERT ON w_warunek
    FOR EACH ROW
    WHEN (
        new.id IS NULL
    )
BEGIN
    :new.id := w_warunek_id_seq.nextval;
END;
/

/*
c) Napisaæ instrukcje PL/SQL, które dla ka¿dego przedmiotu sprawdz¹, czy student ma zaliczony 
ju¿ ten przedmiot (zaliczenie przedmiotu=ocena z egzaminu z dowolnego podejœcia >2.0). 
W przypadku braku zaliczenia sprawdzanego przedmiotu nale¿y dodaæ wpis do tabeli w_warunek z 
informacj¹ jaki student i za jaki przedmiot ile powinien zap³aciæ (przyjmijmy, ¿e kwotê wyliczamy 
wzorem iloœæ_godzin*30 z³). */
DECLARE
    liczba   NUMBER := 0;
BEGIN
    FOR przedmiot IN (SELECT * FROM w_przedmioty) LOOP
        FOR student IN (SELECT * FROM  w_student) LOOP
            SELECT COUNT(*) INTO liczba FROM w_egzamin WHERE przedmioty_id = przedmiot.id
                                                      AND student_id = student.id;
            CASE WHEN liczba = 0 THEN
                INSERT INTO w_warunek ( student_id,przedmioty_id,kwota ) VALUES (
                    student.id,
                    przedmiot.id,
                    ( 30 * przedmiot.ilosc_godzin )
                );

            ELSE
                SELECT MAX(ocena) INTO liczba FROM w_egzamin  WHERE przedmioty_id = przedmiot.id
                                                    AND student_id = student.id
                GROUP BY student_id;
                IF liczba = 2 THEN
                    INSERT INTO w_warunek ( student_id,przedmioty_id,kwota ) VALUES (
                        student.id,
                        przedmiot.id,
                        ( 30 * przedmiot.ilosc_godzin )
                    );
                END IF;
            END CASE;
        END LOOP;
    END LOOP;
EXCEPTION
    WHEN no_data_found THEN
        dbms_output.put_line('blad');
END;
/

