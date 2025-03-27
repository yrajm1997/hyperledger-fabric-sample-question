# Implementing Access Control in a Clinical Data Exchange Hyperledger Fabric Network

## Blockchain Playground Challenge-5 (Hosted on HackerRank)

## Problem Statement

You are tasked with developing a Healthcare Data Exchange Hyperledger Fabric network to securely manage and exchange patient medical data across multiple organizations. The network will consist of three organizations: Clinic, Clinic Management, and Medical Store. Each organization has specific roles and access requirements to ensure data privacy and compliance with healthcare regulations.

- **Clinic**: Provides patient treatment and updates medical records.
- **Clinic Management**: Processes claims and verifies patient eligibility.
- **Medical Store**: Dispenses prescribed medications.

## Requirements

You are required to write a smart contract (chaincode) named **"PatientRecords"** with the following functionalities:

### 1. **Patient Record Management**

- Allow the Clinic to create and update patient records, including medical history, treatment details, and other sensitive data.
- Allow the Clinic Management to read patient records but only those that are relevant to claims processing. Clinic Management cannot update or modify patient records.
- Allow the Medical Store to read prescription-related data from patient records but not access full medical history or treatment details.

### 2. **Access Control**

- Implement audit logging to record who accessed or modified the patient records, ensuring accountability and traceability.

### 3. **Audit Trails**

- Implement audit logging to track who accessed or modified patient records, ensuring full accountability and traceability of all actions.

### 4. **Data Privacy and Security**

- Encrypt sensitive patient information stored on the blockchain to comply with healthcare data privacy regulations (e.g., HIPAA).
- Ensure patient records are secure and only accessible by authorized organizations.

## Deployment Environment

Use the provided pre-configured test network which includes:

- **Five peers**:
  - Two peers for the **Clinic**.
  - Two peers for **Clinic Management**.
  - One peer for the **Medical Store**.
  
- A default channel named `mychannel`.

Ensure the necessary **MSP (Membership Service Providers)** and **endorsement policies** are set for each organization to enforce the correct access control.

## Steps to Test the Smart Contract

1. **Create a new patient record** by the **Clinic**, including medical history, personal details, and prescriptions.
2. **Update a patient record** by the **Clinic**, adding or modifying treatment data.
3. **Access patient records** by **Clinic Management** to verify they can only read data relevant to claims processing.
4. **Access prescription information** by the **Medical Store**, ensuring they can view prescriptions but not access full medical history.
5. **Check audit logs** to verify who accessed or modified patient records, ensuring full traceability and accountability.

## Deployment Steps

### 1. **Deploy the Chaincode**

- Install the "PatientRecords" chaincode on the peers of **Clinic**, **Clinic Management**, and **Medical Store** organizations.
- Instantiate the chaincode on the default channel (`mychannel`).

### 2. **Execute Operations**

- Test the creation, updating, and querying of patient records by the Clinic.
- Test the querying of patient records by Clinic Management for claims processing.
- Test the querying of prescription information by the Medical Store.
- Verify the enforcement of access control policies and the correctness of audit logs.
