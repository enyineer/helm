#!/usr/bin/env python3
# usage ./export_and_wrap.sh <sqlite.db> <prisma-migrationfile.sql> <output-name.sql>
import argparse
import re
import sqlite3
import sys


def parse_migration(migration_path):
    """
    Parse the Prisma SQL migration file to extract table schemas.
    Returns a dict: { table_name: [(col_name, col_type), ...] }
    """
    schema = {}
    content = open(migration_path, 'r').read()
    # Match CREATE TABLE blocks (including multiline bodies)
    for match in re.finditer(r'CREATE TABLE \"?(?P<table>[\w_]+)\"?\s*\((?P<body>.*?)\);', content, re.S):
        table = match.group('table')
        body = match.group('body')
        cols = []
        # Split on commas not inside parentheses
        parts = re.split(r',\s*(?![^()]*\))', body)
        for part in parts:
            part = part.strip()
            # Skip constraints
            if part.upper().startswith(('PRIMARY KEY', 'FOREIGN KEY', 'UNIQUE', 'CHECK', 'CONSTRAINT')):
                continue
            # Column definition: name type ...
            m = re.match(r'\"?(?P<col>[\w_]+)\"?\s+(?P<typ>[A-Z]+)', part, re.I)
            if m:
                col = m.group('col')
                typ = m.group('typ').upper()
                schema.setdefault(table, []).append((col, typ))
    return schema


def format_value(val, col_type):
    if val is None:
        return 'NULL'
    # Boolean
    if 'BOOLEAN' in col_type:
        return 'true' if val else 'false'
    # Timestamp/datetime
    if 'TIMESTAMP' in col_type or 'DATETIME' in col_type:
        try:
            ival = int(val)
            # Milliseconds since epoch
            if ival > 1e12:
                return f"to_timestamp({ival}/1000)"
            # Seconds since epoch
            if 1e9 < ival < 1e12:
                return f"to_timestamp({ival})"
        except Exception:
            pass
        # Default: quote string
        return f"'{val}'"
    # Integer types
    if 'INT' in col_type or 'BIGINT' in col_type or 'INTEGER' in col_type:
        return str(val)
    # Text types
    if 'CHAR' in col_type or 'TEXT' in col_type or 'UUID' in col_type:
        return f"'{str(val).replace("'", "''")}'"
    # Fallback
    return f"'{str(val).replace("'", "''")}'"


def main():
    parser = argparse.ArgumentParser(description='Convert SQLite data to Postgres INSERTs based on Prisma schema')
    parser.add_argument('sqlite_db', help='Path to SQLite database file')
    parser.add_argument('migration_sql', help='Prisma SQL migration file')
    parser.add_argument('output_sql', help='Output SQL file for Postgres import')
    args = parser.parse_args()

    # Parse schema and connect to SQLite
    schema = parse_migration(args.migration_sql)
    conn = sqlite3.connect(args.sqlite_db)
    conn.row_factory = sqlite3.Row

    with open(args.output_sql, 'w') as out:
        # Stop on errors in psql
        out.write('\\set ON_ERROR_STOP on\n')
        # Begin transaction
        out.write('BEGIN;\n')
        out.write("SET session_replication_role = 'replica';\n")

        for table, cols in schema.items():
            if table == '_prisma_migrations':
                continue
            # Count rows for progress
            total = conn.execute(f"SELECT COUNT(*) FROM '{table}'").fetchone()[0]
            # Emit psql echo for table start
            out.write(f"\\echo 'Importing table {table} ({total} rows)'\n")

            names = [c for c, _ in cols]
            col_list = ', '.join(f'"{n}"' for n in names)
            rownum = 0
            for row in conn.execute(f"SELECT * FROM '{table}'"):  # noqa: E999
                vals = []
                for col, typ in cols:
                    vals.append(format_value(row[col], typ) if col in row.keys() else 'NULL')
                val_list = ', '.join(vals)
                out.write(f"INSERT INTO \"{table}\" ({col_list}) VALUES({val_list});\n")
                rownum += 1
                # Per-1000-row echo
                if rownum % 1000 == 0:
                    out.write(f"\\echo '  {rownum}/{total} rows imported for {table}'\n")

            # Emit psql echo for table end
            out.write(f"\\echo 'Finished table {table}'\n")

        out.write("SET session_replication_role = 'origin';\n")
        out.write('COMMIT;\n')

    print(f"✅ Generated {args.output_sql}")

if __name__ == '__main__':
    main()
