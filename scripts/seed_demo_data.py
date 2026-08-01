#!/usr/bin/env python3
"""Seed demo tenants and enquiries into the DSS Lets Firestore project.

Usage:
  python3 scripts/seed_demo_data.py --service-account /path/to/key.json

The service-account argument can be omitted when
GOOGLE_APPLICATION_CREDENTIALS is set. The script reads property IDs before
creating any records and prints every created document ID.
"""

from __future__ import annotations

import argparse
import os
import random
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path

try:
    import firebase_admin
    from firebase_admin import credentials, firestore
except ImportError:
    print(
        "firebase-admin is required. Install it with: "
        "python3 -m pip install firebase-admin",
        file=sys.stderr,
    )
    raise SystemExit(2)

PROJECT_ID = "dss-lets"
SEED = 20260731

TENANTS = [
    {"fullname": "Amelia Carter", "phone": "+44 7700 900101", "email": "amelia.carter.demo@example.com", "preferredArea": "London", "benefitType": "UC", "moveDays": 14},
    {"fullname": "Daniel Hughes", "phone": "+44 7700 900102", "email": "daniel.hughes.demo@example.com", "preferredArea": "Manchester", "benefitType": "Housing Benefit", "moveDays": 28},
    {"fullname": "Priya Shah", "phone": "+44 7700 900103", "email": "priya.shah.demo@example.com", "preferredArea": "Birmingham", "benefitType": "PIP", "moveDays": 42},
    {"fullname": "Connor McLeod", "phone": "+44 7700 900104", "email": "connor.mcleod.demo@example.com", "preferredArea": "Leeds", "benefitType": "ESA", "moveDays": 56},
    {"fullname": "Sophie Macdonald", "phone": "+44 7700 900105", "email": "sophie.macdonald.demo@example.com", "preferredArea": "Glasgow", "benefitType": "UC", "moveDays": 70},
    {"fullname": "Marcus Williams", "phone": "+44 7700 900106", "email": "marcus.williams.demo@example.com", "preferredArea": "Bristol", "benefitType": "Housing Benefit", "moveDays": 84},
]
STATUSES = ("new", "contacted", "viewing", "approved")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--service-account",
        type=Path,
        help="Firebase service-account JSON (or set GOOGLE_APPLICATION_CREDENTIALS)",
    )
    parser.add_argument("--project", default=PROJECT_ID, help="Firebase project ID (default: dss-lets)")
    return parser.parse_args()


def init_firestore(service_account: Path | None, project: str):
    if firebase_admin._apps:
        return firestore.client()
    key_path = service_account or (
        Path(os.environ["GOOGLE_APPLICATION_CREDENTIALS"])
        if os.environ.get("GOOGLE_APPLICATION_CREDENTIALS")
        else None
    )
    if key_path:
        if not key_path.is_file():
            raise FileNotFoundError(f"Service-account file not found: {key_path}")
        app = firebase_admin.initialize_app(credentials.Certificate(str(key_path)), {"projectId": project})
    else:
        # This uses Application Default Credentials (for example, GOOGLE_APPLICATION_CREDENTIALS).
        app = firebase_admin.initialize_app(options={"projectId": project})
    return firestore.client(app)


def main() -> int:
    args = parse_args()
    try:
        db = init_firestore(args.service_account, args.project)

        # Read IDs first, as required, and fail before writing if there are none.
        property_ids = [doc.id for doc in db.collection("properties").stream()]
        if not property_ids:
            raise RuntimeError("No documents found in properties; refusing to create enquiries.")
        print(f"Read {len(property_ids)} property IDs: {', '.join(property_ids)}")

        now = datetime.now(timezone.utc)
        tenant_refs = []
        tenant_payloads = []
        for tenant in TENANTS:
            ref = db.collection("tenants").document()
            tenant_refs.append(ref)
            payload = {key: value for key, value in tenant.items() if key != "moveDays"}
            payload["moveDate"] = now + timedelta(days=tenant["moveDays"])
            tenant_payloads.append(payload)

        # Generate deterministic links/statuses for repeatable demo runs while keeping auto IDs.
        rng = random.Random(SEED)
        enquiry_refs = []
        enquiry_payloads = []
        for index in range(10):
            ref = db.collection("enquiries").document()
            enquiry_refs.append(ref)
            enquiry_payloads.append({
                "propertyId": rng.choice(property_ids),
                "tenantId": tenant_refs[rng.randrange(len(tenant_refs))].id,
                "status": STATUSES[index % len(STATUSES)],
            })

        batch = db.batch()
        for ref, payload in zip(tenant_refs, tenant_payloads):
            batch.set(ref, payload)
        for ref, payload in zip(enquiry_refs, enquiry_payloads):
            batch.set(ref, payload)
        batch.commit()

        print(f"Created {len(tenant_refs)} tenants:")
        for ref, payload in zip(tenant_refs, tenant_payloads):
            print(f"  tenants/{ref.id} — {payload['fullname']}")
        print(f"Created {len(enquiry_refs)} enquiries:")
        for ref, payload in zip(enquiry_refs, enquiry_payloads):
            print(f"  enquiries/{ref.id} — property={payload['propertyId']}, tenant={payload['tenantId']}, status={payload['status']}")
        return 0
    except Exception as exc:
        print(f"Seed failed: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
