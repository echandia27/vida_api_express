CREATE EXTENSION IF NOT EXISTS "pgcrypto";

--specialities
CREATE TABLE IF NOT EXISTS med.specialties (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL UNIQUE,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

--doctors
CREATE TABLE IF NOT EXISTS med.doctors (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name VARCHAR(120) NOT NULL,
  email VARCHAR(120) UNIQUE NOT NULL,
  specialty_id UUID NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_doctors_specialty
    FOREIGN KEY (specialty_id) REFERENCES med.specialties(id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_doctors_specialty_id ON med.doctors(specialty_id);

--patients
CREATE TABLE IF NOT EXISTS med.patients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name VARCHAR(120) NOT NULL,
  email VARCHAR(120) UNIQUE NOT NULL,
  phne VARCHAR(30) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

--APPOINTMENTS
CREATE TABLE IF NOT EXISTS med.appointments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id UUID NOT NULL,
  doctor_id UUID NOT NULL,
  specialty_id UUID NOT NULL,
  scheduled_at TIMESTAMP NOT NULL,
  reason TEXT,
  status VARCHAR(20) NOT NULL DEFAULT 'scheduled', -- scheduled, cancelled, completed
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),

  CONSTRAINT fk_appointments_patient
    FOREIGN KEY (patient_id) REFERENCES med.patients(id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,

  CONSTRAINT fk_appointments_doctor
    FOREIGN KEY (doctor_id) REFERENCES med.doctors(id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,

  CONSTRAINT fk_appointments_specialty
    FOREIGN KEY (specialty_id) REFERENCES med.specialties(id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_appointments_patient_id ON med.appointments(patient_id);
CREATE INDEX IF NOT EXISTS idx_appointments_doctor_id ON med.appointments(doctor_id);
CREATE INDEX IF NOT EXISTS idx_appointments_scheduled_at ON med.appointments(scheduled_at);

--PAYMENTS
CREATE TABLE IF NOT EXISTS med.payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  appointment_id UUID NOT NULL UNIQUE,
  amount NUMERIC(12,2) NOT NULL CHECK (amount >= 0),
  method VARCHAR(30) NOT NULL, -- cash, card, transfer...
  paid_at TIMESTAMP NOT NULL DEFAULT NOW(),

  CONSTRAINT fk_payments_appointment
    FOREIGN KEY (appointment_id) REFERENCES med.appointments(id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_payments_appointment_id ON med.payments(appointment_id);

--PRESCRIPTIONS
CREATE TABLE IF NOT EXISTS med.prescriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  appointment_id UUID NOT NULL,
  medication VARCHAR(120) NOT NULL,
  dosage VARCHAR(120) NOT NULL,
  instructions TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),

  CONSTRAINT fk_prescriptions_appointment
    FOREIGN KEY (appointment_id) REFERENCES med.appointments(id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_prescriptions_appointment_id ON med.prescriptions(appointment_id);

------------- INSERSION EN LA BASE DE DATOS --------------------
--SPECIALTIES
INSERT INTO med.specialties (name)
SELECT 'Specialty ' || gs
FROM generate_series(1, 100) gs
ON CONFLICT (name) DO NOTHING;

--DOCTORS
INSERT INTO med.doctors (full_name, email, specialty_id)
SELECT
  'Doctor ' || gs AS full_name,
  'doctor' || gs || '@example.com' AS email,
  (SELECT id FROM med.specialties ORDER BY random() LIMIT 1) AS specialty_id
FROM generate_series(1, 100) gs;

---PATIENTS-
INSERT INTO med.patients (full_name, email, phone)
SELECT
  'Patient ' || gs AS full_name,
  'patient' || gs || '@example.com' AS email,
  '+57' || (1000000000 + (random() * 8999999999)::bigint)::text AS phone
FROM generate_series(1, 100) gs;

--APPOINTMENTS
INSERT INTO med.appointments (patient_id, doctor_id, specialty_id, scheduled_at, reason, status)
SELECT
  p.id AS patient_id,
  d.id AS doctor_id,
  d.specialty_id AS specialty_id,
  (NOW() + ((random() * 60)::int || ' days')::interval + ((random() * 10)::int || ' hours')::interval) AS scheduled_at,
  'Reason ' || substr(md5(random()::text), 1, 12) AS reason,
  'scheduled' AS status
FROM generate_series(1, 100) gs
JOIN LATERAL (SELECT id FROM med.patients ORDER BY random() LIMIT 1) p ON true
JOIN LATERAL (SELECT id, specialty_id FROM med.doctors ORDER BY random() LIMIT 1) d ON true;

--PAYMENTS
INSERT INTO med.payments (appointment_id, amount, method, paid_at)
SELECT
  a.id AS appointment_id,
  (50 + (random() * 450))::numeric(12,2) AS amount,
  (ARRAY['cash','card','transfer'])[1 + floor(random() * 3)] AS method,
  NOW() - ((random() * 10)::int || ' days')::interval AS paid_at
FROM med.appointments a
ORDER BY a.created_at ASC
LIMIT 100;

--PRESCRIPTIONS 
INSERT INTO med.prescriptions (appointment_id, medication, dosage, instructions)
SELECT
  a.id AS appointment_id,
  (ARRAY['Ibuprofen','Paracetamol','Amoxicillin','Metformin','Loratadine','Omeprazole','Azithromycin','Atorvastatin'])[1 + floor(random() * 8)] AS medication,
  (ARRAY['250mg','500mg','850mg','10mg','20mg','1g'])[1 + floor(random() * 6)] AS dosage,
  'Take ' || (1 + floor(random() * 3))::int || ' times per day for ' || (3 + floor(random() * 10))::int || ' days'
FROM generate_series(1, 100) gs
JOIN LATERAL (SELECT id FROM med.appointments ORDER BY random() LIMIT 1) a ON true;

--VERIFICACION 
SELECT 'specialties' AS table, COUNT(*) FROM med.specialties
UNION ALL
SELECT 'doctors', COUNT(*) FROM med.doctors
UNION ALL
SELECT 'patients', COUNT(*) FROM med.patients
UNION ALL
SELECT 'appointments', COUNT(*) FROM med.appointments
UNION ALL
SELECT 'payments', COUNT(*) FROM med.payments
UNION ALL
SELECT 'prescriptions', COUNT(*) FROM med.prescriptions;

------- OTRO COSA DIFERENTE

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE echandia.specialty (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE echandia.doctor (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(150) NOT NULL,
    specialty_id UUID NOT NULL,
    FOREIGN KEY (specialty_id) REFERENCES echandia.specialty(id)
);

CREATE TABLE echandia.patient (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(150) NOT NULL,
    birth_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE echandia.appointment (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL,
    doctor_id UUID NOT NULL,
    appointment_date DATE NOT NULL,
    cost NUMERIC(10,2) NOT NULL,
    diagnosis TEXT,
    FOREIGN KEY (patient_id) REFERENCES echandia.patient(id),
    FOREIGN KEY (doctor_id) REFERENCES echandia.doctor(id)
);

CREATE TABLE echandia.payment (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    appointment_id UUID UNIQUE NOT NULL,
    amount NUMERIC(10,2) NOT NULL,
    payment_date DATE NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    FOREIGN KEY (appointment_id) REFERENCES echandia.appointment(id)
);

CREATE TABLE echandia.prescription (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    appointment_id UUID NOT NULL,
    medication_name VARCHAR(150) NOT NULL,
    dosage VARCHAR(100) NOT NULL,
    duration_days INT NOT NULL,
    FOREIGN KEY (appointment_id) REFERENCES echandia.appointment(id)
);

--insertar

INSERT INTO echandia.specialty (name) VALUES
('Cardiología'),
('Pediatría'),
('Dermatología'),
('Neurología'),
('Ginecología');

--doctor
INSERT INTO echandia.doctor (name, specialty_id)
SELECT 'Dr. Juan Pérez', id FROM echandia.specialty WHERE name = 'Cardiología';

INSERT INTO echandia.doctor (name, specialty_id)
SELECT 'Dra. María Gómez', id FROM echandia.specialty WHERE name = 'Pediatría';

INSERT INTO echandia.doctor (name, specialty_id)
SELECT 'Dr. Carlos Ramírez', id FROM echandia.specialty WHERE name = 'Dermatología';

INSERT INTO echandia.doctor (name, specialty_id)
SELECT 'Dra. Laura Torres', id FROM echandia.specialty WHERE name = 'Neurología';

INSERT INTO echandia.doctor (name, specialty_id)
SELECT 'Dr. Andrés Molina', id FROM echandia.specialty WHERE name = 'Ginecología';

--patient
INSERT INTO echandia.patient (name, birth_date) VALUES
('Ana Martínez', '1990-05-14'),
('Luis Fernández', '1985-09-22'),
('Sofía Herrera', '2000-12-01'),
('Miguel Castro', '1978-03-30'),
('Valentina Rojas', '1995-07-18');

--appointment
INSERT INTO echandia.appointment (patient_id, doctor_id, appointment_date, cost, diagnosis)
SELECT p.id, d.id, '2026-02-10', 150.00, 'Hipertensión'
FROM echandia.patient p, echandia.doctor d
WHERE p.name = 'Ana Martínez' AND d.name = 'Dr. Juan Pérez';

INSERT INTO echandia.appointment (patient_id, doctor_id, appointment_date, cost, diagnosis)
SELECT p.id, d.id, '2026-02-11', 120.00, 'Infección viral'
FROM echandia.patient p, echandia.doctor d
WHERE p.name = 'Luis Fernández' AND d.name = 'Dra. María Gómez';

INSERT INTO echandia.appointment (patient_id, doctor_id, appointment_date, cost, diagnosis)
SELECT p.id, d.id, '2026-02-12', 180.00, 'Dermatitis'
FROM echandia.patient p, echandia.doctor d
WHERE p.name = 'Sofía Herrera' AND d.name = 'Dr. Carlos Ramírez';

INSERT INTO echandia.appointment (patient_id, doctor_id, appointment_date, cost, diagnosis)
SELECT p.id, d.id, '2026-02-13', 200.00, 'Migraña crónica'
FROM echandia.patient p, echandia.doctor d
WHERE p.name = 'Miguel Castro' AND d.name = 'Dra. Laura Torres';

INSERT INTO echandia.appointment (patient_id, doctor_id, appointment_date, cost, diagnosis)
SELECT p.id, d.id, '2026-02-14', 160.00, 'Control prenatal'
FROM echandia.patient p, echandia.doctor d
WHERE p.name = 'Valentina Rojas' AND d.name = 'Dr. Andrés Molina';

--payment
INSERT INTO echandia.payment (appointment_id, amount, payment_date, payment_method)
SELECT id, 150.00, '2026-02-10', 'Tarjeta'
FROM echandia.appointment WHERE diagnosis = 'Hipertensión';

INSERT INTO echandia.payment (appointment_id, amount, payment_date, payment_method)
SELECT id, 120.00, '2026-02-11', 'Efectivo'
FROM echandia.appointment WHERE diagnosis = 'Infección viral';

INSERT INTO echandia.payment (appointment_id, amount, payment_date, payment_method)
SELECT id, 180.00, '2026-02-12', 'Transferencia'
FROM echandia.appointment WHERE diagnosis = 'Dermatitis';

INSERT INTO echandia.payment (appointment_id, amount, payment_date, payment_method)
SELECT id, 200.00, '2026-02-13', 'Tarjeta'
FROM echandia.appointment WHERE diagnosis = 'Migraña crónica';

INSERT INTO echandia.payment (appointment_id, amount, payment_date, payment_method)
SELECT id, 160.00, '2026-02-14', 'Efectivo'
FROM echandia.appointment WHERE diagnosis = 'Control prenatal';

--prescription
INSERT INTO echandia.prescription (appointment_id, medication_name, dosage, duration_days)
SELECT id, 'Losartán', '50mg una vez al día', 30
FROM echandia.appointment WHERE diagnosis = 'Hipertensión';

INSERT INTO echandia.prescription (appointment_id, medication_name, dosage, duration_days)
SELECT id, 'Paracetamol', '500mg cada 8 horas', 5
FROM echandia.appointment WHERE diagnosis = 'Infección viral';

INSERT INTO echandia.prescription (appointment_id, medication_name, dosage, duration_days)
SELECT id, 'Hidrocortisona crema', 'Aplicar dos veces al día', 10
FROM echandia.appointment WHERE diagnosis = 'Dermatitis';

INSERT INTO echandia.prescription (appointment_id, medication_name, dosage, duration_days)
SELECT id, 'Sumatriptán', '50mg en caso de dolor', 15
FROM echandia.appointment WHERE diagnosis = 'Migraña crónica';

INSERT INTO echandia.prescription (appointment_id, medication_name, dosage, duration_days)
SELECT id, 'Ácido fólico', '1 tableta diaria', 90
FROM echandia.appointment WHERE diagnosis = 'Control prenatal';