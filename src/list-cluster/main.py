
import json
import functions_framework
import firebase_admin
from flask import Response
from firebase_admin import credentials
from firebase_admin import firestore

cred = credentials.ApplicationDefault()
firebase_admin.initialize_app(cred)
db = firestore.client()

def get_clusters():
    docs = db.collection('clusters').stream()
    clusters_name = []
    for doc in docs:
        if 'name' in doc.to_dict(): 
            clusters_name.append(doc.id)
        
    return Response(response = json.dumps(clusters_name), status = 200, content_type = 'application/json')

def get_cluster(clustername):
    doc_ref = db.collection('clusters').document(clustername)
    doc = doc_ref.get()
    if doc.exists:
        return Response(response = json.dumps(doc.to_dict()), status = 200, content_type = 'application/json')

@functions_framework.http
def main(request):
    request_args = request.args        
    if request_args and 'name' in request_args:
        return get_cluster(request_args['name'])
    else:
        return get_clusters()
