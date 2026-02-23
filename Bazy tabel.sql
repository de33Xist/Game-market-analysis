use master
go


CREATE TABLE kraje
(
    ID_Kraj INT IDENTITY(1,1) PRIMARY KEY,
    Kraj VARCHAR(100) NOT NULL
);

CREATE TABLE wydawcy
(
    ID_Wydawcy INT IDENTITY(1,1) PRIMARY KEY,
    Nazwa_wydawcy VARCHAR(100) NOT NULL,
    ID_Kraj INT NOT NULL,
    Rok_zalozenia INT,
    FOREIGN KEY (ID_Kraj) REFERENCES kraje(ID_Kraj)
);

CREATE TABLE gry_baza
(
    ID_Gry INT IDENTITY(1,1) PRIMARY KEY,
    Nazwa_gry VARCHAR(100) NOT NULL UNIQUE,
    Rodzaj_gry VARCHAR(100) NOT NULL,
	Przeznaczenie VARCHAR(1000) NOT NULL,
    ID_Wydawcy INT NOT NULL,
    Data_premiery DATE,
    FOREIGN KEY (ID_Wydawcy) REFERENCES wydawcy(ID_Wydawcy)
);

CREATE TABLE ceny
(
    ID_Ceny INT IDENTITY(1,1) PRIMARY KEY,
    ID_Gry INT NOT NULL,
    Cena_PLN DECIMAL(10,2),
    Cena_USD DECIMAL(10,2),
    Cena_Euro DECIMAL(10,2),
    FOREIGN KEY (ID_Gry) REFERENCES gry_baza(ID_Gry)
);

CREATE TABLE wynagrodzenia_minimalne
(
    ID_Wynagrodzenia INT IDENTITY(1,1) PRIMARY KEY,
    ID_Kraj INT NOT NULL,
    Rok INT NOT NULL,
    Wynagrodzenie DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (ID_Kraj) REFERENCES kraje(ID_Kraj)
);

CREATE TABLE wynagrodzenia_przeciêtne
(
    ID_Wynagrodzenia INT IDENTITY(1,1) PRIMARY KEY,
    ID_Kraj INT NOT NULL,
    Rok INT NOT NULL,
    Wynagrodzenie DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (ID_Kraj) REFERENCES kraje(ID_Kraj)
);

CREATE TABLE wynagrodzenia_œrednia
(
    ID_Wynagrodzenia INT IDENTITY(1,1) PRIMARY KEY,
    ID_Kraj INT NOT NULL,
    Rok INT NOT NULL,
    Wynagrodzenie DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (ID_Kraj) REFERENCES kraje(ID_Kraj)
);
