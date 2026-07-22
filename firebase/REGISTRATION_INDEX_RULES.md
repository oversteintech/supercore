# Shared registration index rules (all Super Apps)

Copy these match blocks into each product `firestore.rules` that shares the
AfterArtificial Firebase backend. Public **get** (not list) lets signup show
username / garage-id availability before the user is signed in.

```
match /usernames/{usernameLower} {
  allow get: if true;
  allow list: if signedIn();
  allow create, update: if signedIn() && request.resource.data.uid == request.auth.uid;
  allow delete: if signedIn() && resource.data.uid == request.auth.uid;
}

match /garageIds/{garageId} {
  allow get: if true;
  allow list: if signedIn();
  allow create, update: if signedIn() && request.resource.data.uid == request.auth.uid;
  allow delete: if isSuperAdmin();
}
```

Phone / email indexes stay signed-in-only (PII).

Client code: `RegistrationIndexClient` in `after_firebase` — never throws on
permission-denied; returns `null` so wizards stay optimistic.
