module PrescriptionTracker::PrescriptionTracker {
    use std::signer;
    use aptos_framework::timestamp;

    /// Struct to store prescription details
    struct Prescription has key, store {
        patient_address: address,
        medicine: vector<u8>,
        dosage: u64,
        expiry_timestamp: u64,
        is_valid: bool
    }

    /// Error codes
    const E_PRESCRIPTION_EXISTS: u64 = 1;
    const E_PRESCRIPTION_EXPIRED: u64 = 2;
    const E_UNAUTHORIZED: u64 = 3;
    const E_INVALID_PRESCRIPTION: u64 = 4;

    /// Function to create a new prescription
    public fun create_prescription(
        doctor: &signer,
        patient_addr: address,
        medicine: vector<u8>,
        dosage: u64,
        validity_duration: u64
    ) {
        let prescription = Prescription {
            patient_address: patient_addr,
            medicine: medicine,
            dosage: dosage,
            expiry_timestamp: timestamp::now_seconds() + validity_duration,
            is_valid: true
        };
        move_to(doctor, prescription);
    }

    /// Function to update prescription status
    public fun update_prescription_status(
        authority: &signer,
        patient_addr: address,
        new_status: bool
    ) acquires Prescription {
        let auth_addr = signer::address_of(authority);
        let prescription = borrow_global_mut<Prescription>(auth_addr);
        
        assert!(prescription.patient_address == patient_addr, E_UNAUTHORIZED);
        assert!(prescription.expiry_timestamp > timestamp::now_seconds(), E_PRESCRIPTION_EXPIRED);
        
        prescription.is_valid = new_status;
    }
}