
import json
import functions_framework
import firebase_admin
from flask import Response
from firebase_admin import credentials
from firebase_admin import firestore

cred = credentials.ApplicationDefault()
firebase_admin.initialize_app(cred)
db = firestore.client()

def set_cluster(data):
    doc_ref = db.collection('clusters').document(data['name'])
    doc = doc_ref.get()
    doc_ref.set(data)
    return Response(response = "Updated!", status = 200)

@functions_framework.http
def main(request):
    request_json = request.get_json(silent=True)
    if request_json and 'name' in request_json:
        return set_cluster(request_json)
    else:
        return Response(response = "No data!", status = 200)

