
import json
import functions_framework
import firebase_admin
from flask import Response
from firebase_admin import credentials
from firebase_admin import firestore

cred = credentials.ApplicationDefault()
firebase_admin.initialize_app(cred)
db = firestore.client()

def del_cluster(clustername):
    doc_ref = db.collection('clusters').document(clustername)
    doc = doc_ref.get()
    if doc.exists:
        doc_ref.delete()
        return Response(response = "Deleted!", status = 200)
    else:
        return Response(response = "Document not exist!", status = 200)

@functions_framework.http
def main(request):
    from flask import abort
    if request.method == 'DELETE':
        request_args = request.args
        if request_args and 'name' in request_args:
            return del_cluster(request_args['name'])
        else:
            return Response(response = "No data!", status = 200)
    else:
        return abort(405)
