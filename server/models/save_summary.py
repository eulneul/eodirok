import psycopg2
from psycopg2 import sql
from create_db import UserDatabaseManager
9
class SummaryDBManager(UserDatabaseManager):
    def __init__(self, admin_config):
        super().__init__(admin_config)

    def create_summary_table(self, connection, summary_name):
        """
        프로젝트별 테이블 생성
        """
        table_name = self.get_table_name(summary_name)
        query = f"""
        CREATE TABLE IF NOT EXISTS {table_name} (
            id SERIAL PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            description TEXT,
            summary_at TIMESTAMP,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """
        try:
            self.execute_crud(connection,query)
            print(f"TABLE '{table_name}' created successfully.")
        except Exception as e:
            print(f"Error creating summary table: {e}")

    def execute_summary_crud(self, connection, summary_name, query, params=None):
        table_name = self.get_table_name(summary_name)
        formatted_query = query.format(table = table_name)
        try:
            return self.execute_crud(connection, formatted_query, params)
        except Exception as e:
            print(f"Error executing CRUD on summary table'{table_name}: {e}")

    def get_table_name(self, summary_name):
        return f"summary_{summary_name.lower().replace(' ', '_')}"
    
#예시 코드드-
if __name__ == "__main__":
    file_path = 'admin_info.txt'

    with open(file_path, 'r') as file:
        lines = file.readlines()

    localhost = lines[0].strip()
    dbname = lines[1].strip()
    user = lines[2].strip()
    password = lines[3].strip()
    port = int(lines[4].strip())

    admin_config = {
        'host': localhost,
        'dbname': dbname,
        'user': user,
        'password': password,
        'port': port
    }
    
    # Initialize the PjDBManager
    manager = SummaryDBManager(admin_config)
    
    # Create user-specific database
    user_id = "12345"
    manager.create_user_database(user_id)
    
    # Connect to the user-specific database
    user_connection = manager.connect_user_database(user_id)
    
    # Create a table for a summary
    summary_name = "My First Summary"
    manager.create_summary_table(user_connection, summary_name)
    
    # Insert data into the summary table
    insert_query = "INSERT INTO {table} (name, description, summary_at) VALUES (%s, %s, %s)"
    manager.execute_summary_crud(
        user_connection,
        summary_name,
        insert_query,
        params=("", "This is a description of the task.", "2024-11-27")
    )
    
    # Fetch data from the summary table
    select_query = "SELECT * FROM {table}"
    results = manager.execute_summary_crud(user_connection, summary_name, select_query)
    print("Data from summary table:", results)
    
    # Clean up
    manager.close_connection(user_connection)
    manager.delete_user_database(user_id)
    manager.close_admin_connection()