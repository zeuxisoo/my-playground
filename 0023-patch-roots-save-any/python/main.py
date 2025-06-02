#!/usr/bin/env python

import argparse
import json
import os
from datetime import datetime, timedelta
from kind import Quality

def get_latest_save_file(config: dict):
    save_latest_at = 0
    save_latest_file = ""
    save_time_ats = {}

    for save_file in ('save.json', 'save-int.json', 'save-prev.json'):
        file_path = os.path.join(config['save_path'], save_file)

        file_handler = open(file_path, 'r')
        save_object = json.loads(file_handler.read())
        file_handler.close()

        save_timestamp = save_object['Timestamp']

        if save_latest_at == 0 and save_latest_file == "":
            save_latest_at = save_timestamp
            save_latest_file = save_file

        timetamp, milliseconds = divmod(save_timestamp, 1000)
        date_object = datetime.fromtimestamp(timetamp) + timedelta(milliseconds=milliseconds)

        save_time_ats[save_file] = {
            'timestamp': save_timestamp,
            'datetime' : str(date_object)
        }

        if save_timestamp > save_latest_at:
            save_latest_at = save_timestamp
            save_latest_file = save_file

    return save_latest_file

class Inventory:
    def __init__(self, save_object: dict):
        self.save_object = save_object
        self.entities = self.save_object['Entities']

    def get_id(self) -> str:
        for entity in self.entities:
            if entity['Type'] == 4:
                return entity['InventoryId']

        raise RuntimeError('Cannot find inventory id')

    def get_object(self, id: str) -> dict:
        for entity in self.entities:
            if entity['Type'] == 5 and entity['ID'] == id:
                return entity

        raise RuntimeError('Cannot find inventory data')

    def get_regular_slots(self, inventory_object: dict) -> list:
        return inventory_object['RegularSlots']

def run(config: dict):
    config['save_full_path'] = os.path.join(
        config['save_path'],
        get_latest_save_file(config) if config['auto_find'] else config['save_file']
    )

    if os.path.exists(config['save_full_path']) is False:
        raise RuntimeError('Cannot find save file: {}'.format(config['save_full_path']))

    save_content = open(config['save_full_path']).read()
    save_object = json.loads(save_content)

    inventory = Inventory(save_object)
    inventory_id = inventory.get_id()
    inventory_object = inventory.get_object(inventory_id)
    inventory_regular_slots = inventory.get_regular_slots(inventory_object)

    for slot in inventory_regular_slots:
        if 'ItemWithProperties' in slot:
            slot['ItemWithProperties']['Quality'] = config['inventory']['quality']
            slot['SyncedQ'] = config['inventory']['synced_q']

    with open(config['save_full_path'], 'w+') as f:
        f.write(json.dumps(save_object))

def main():
    parser = argparse.ArgumentParser(
        prog='max inventory',
        description='maximum the inventory'
    )
    parser.add_argument('--auto', action='store_true', default=False, help='enable auto find save mode')
    parser.add_argument('-p', '--path', required=True, help='which save path should be searched')
    parser.add_argument('-f', '--file', required=True, help='which save file should be used')
    parser.add_argument('--quality', type=int, default=Quality.Best.value, help='which item quality should be set [0-3, default: 3]')
    parser.add_argument('--amount', type=int, default=255, help='how many item amount should be set [1-255, default: 255]')

    args = parser.parse_args()

    # save path should be like
    # mac: $HOME/Library/Application Support/Soda Den/Roots of Pacha/saves/[USER_ID]
    # win: %USERPROFILE%\AppData\LocalLow\Soda Den\Roots of Pacha\saves\[USER_ID]
    # config = {
    #     'auto_find': False,
    #     'save_path': '/Users/[NAME]/Library/Application Support/Soda Den/Roots of Pacha/saves/[USER_ID]/[SAVE_ID]/',
    #     'save_file': 'save-int.json', # save.json or save-prev.json
    #     'inventory': {
    #         'quality' : Quality.Best.value,
    #         'synced_q': 255, # total of item
    #     }
    # }
    config = {
        'auto_find': args.auto,
        'save_path': args.path,
        'save_file': args.file,
        'inventory': {
            'quality' : args.quality,
            'synced_q': args.amount,
        }
    }
    run(config)

if __name__ == "__main__":
    main()
