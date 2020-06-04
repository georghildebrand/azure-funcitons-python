import logging
import uuid
import json

import azure.functions as func


def main(msg: func.QueueMessage, message: func.Out[str]) -> None:
    body = json.loads(msg.get_body().decode('utf-8'))
    logging.info('Python queue trigger function processed a queue item: %s',
                 body)

    rowKey = str(uuid.uuid4())
    data = {
        "Name": "Item Table",
        "PartitionKey": "message",
        "RowKey": rowKey,
        "id_a": body["id_a"],
        "id_b": body["id_b"]
    }
    message.set(json.dumps(data))
