#!/usr/bin/env python3

# This python script will open up Acorn images and write out its layers as png/tiff/plist (for vector layers).

import argparse
import sqlite3
import os
import sys

def writeComposite(args, cursor):
    
    compositeExtension = None
    
    cursor.execute("select hex(substr(value, 1, 4)) from  image_attributes where name = 'composite'")
    row = cursor.fetchone()
    
    if row is not None:
        if row[0] == "89504E47":
            compositeExtension = "png"
        elif row[0] == "4D4D002A":
            compositeExtension = "tiff"
        else:
            print(f"Unknown composite type: {row[0]}")
        
        if compositeExtension is not None:
            cursor.execute("select value from image_attributes where name = 'composite'")
            compRow = cursor.fetchone()
            
            if compRow is not None:
                compositePath = args.output_folder + f"/composite.{compositeExtension}"
                with open(compositePath, 'wb') as f:
                    f.write(compRow[0])
                

def writeLayerData(args, cursor):
    
    cursor.execute("select id, uti, name, data from layers")
    rows = cursor.fetchall()
    
    for row in rows:
        
        ext = None
        uti = row[1]
        if uti == "public.png":
            ext = "png"
        elif uti == "public.tiff":
            ext = "tiff"
        elif uti == "com.flyingmeat.acorn.shapelayer":
            ext = "plist"
        elif uti == "com.acorn.group":
            print("Not currently handling groups")
            continue
        else:
            print(f"Unknown UTI: {uti}")
            continue
        
        fileName = f"{row[0]}-{row[2]}.{ext}"
        filePath = f"{args.output_folder}/{fileName}"
        with open(filePath, 'wb') as f:
            f.write(row[3])
        
def main():
    parser = argparse.ArgumentParser(description='Process a Acorn image and output results to a folder.')
    parser.add_argument('acorn_file_path', help='Path to the Acorn database file')
    parser.add_argument('output_folder', help='Path to the output folder')
    args = parser.parse_args()

    # Ensure output folder exists
    os.makedirs(args.output_folder, exist_ok=True)

    # Connect to the database
    try:
        conn = sqlite3.connect(args.acorn_file_path)
    except sqlite3.Error as e:
        print(f"Error connecting to .acorn database: {e}", file=sys.stderr)
        sys.exit(1)

    #try:
    cursor = conn.cursor()
    
    writeComposite(args, cursor)
    writeLayerData(args, cursor)
    
    '''
    except Exception as e:
        print(f"Error processing database: {e}", file=sys.stderr)
    finally:'''
    
    conn.close()

if __name__ == '__main__':
    main()