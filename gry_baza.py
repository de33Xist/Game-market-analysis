import pandas as pd
import pyodbc
import logging

logging.basicConfig(
    filename=r"C:\Users\genma\Desktop\logi raport gry\automat.log",
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)


conn_str  = (
    "Driver={ODBC Driver 17 for SQL Server};"
    "Server=DESKTOP-A3FJITF;"
    "Database=raport_gry;"
    "Trusted_Connection=yes;"
)

logging.info("Start procesu importu")

try:
    df = pd.read_excel(r'C:\Users\genma\Desktop\automat\baza.xlsx')
    logging.info("Wczytano plik")
    df = df.where(df.notna(),None)
    logging.info(f"Liczba rekordów: {len(df)}")

    insert_sql = "INSERT INTO gry_baza (nazwa_gry,rodzaj_gry,przeznaczenie,id_wydawcy,data_premiery) values (?,?,?,?,?)"

    conn = pyodbc.connect(conn_str)
    logging.info("Połączono z baza")

    cursor = conn.cursor()
    cursor.fast_executemany = True

    for row in df.itertuples(index=False, name=None):
        cleaned_row = []  # reset listy dla każdego wiersza
        for value in row:
            if pd.isna(value):
                cleaned_row.append(None)
            else:
                cleaned_row.append(value)
        row_tuple = tuple(cleaned_row)
        cursor.execute(insert_sql, row_tuple)


    conn.commit()
    logging.info("Insert zakonczony sukcesem")

    cursor.close()

except Exception as e :
    logging.error(f"Wystapil blad: {e}")

finally:
    if 'conn' in locals():
        conn.close()
        logging.info("Polaczenie zamkniete")


