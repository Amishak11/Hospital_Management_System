from flask import Flask, render_template, request,flash, redirect
import mysql.connector

app = Flask(__name__, template_folder='templates')

app.secret_key='your_secret_key'
conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="Amisha2005",
    database="Hospital"
)
cursor = conn.cursor()


@app.route('/')
def home():
    return render_template('index.html')


@app.route('/add_patient', methods=['GET', 'POST'])
def add_patient():
    if request.method == 'POST':
        name = request.form['name']
        age = request.form['age']
        gender = request.form['gender']
        contact = request.form['contact']

     
        cursor.callproc("AddPatient", (name, age, gender, contact))
        conn.commit()

        return redirect('/patients')

    return render_template('add_patient.html')


@app.route('/patients')
def view_patients():
    cursor.callproc("GetAllPatients")  
    for result in cursor.stored_results():
        patients = result.fetchall()

    return render_template('patients.html', patients=patients)


@app.route('/book_appointment', methods=['GET', 'POST'])
def book_appointment():
    cursor = conn.cursor()

  
    cursor.execute("SELECT patient_id, name FROM Patients")
    patients = cursor.fetchall()

   
    cursor.execute("SELECT DISTINCT doctor_name FROM Appointments")
    doctors = [row[0] for row in cursor.fetchall()]

  
    if not doctors:
        doctors = ["Dr. Smith", "Dr. Johnson", "Dr. Williams"]

    if request.method == 'POST':
        patient_id = request.form['patient_id']
        doctor_name = request.form['doctor_name']
        appointment_date = request.form['appointment_date']

        try:
            cursor.callproc("BookAppointment", (patient_id, doctor_name, appointment_date))
            conn.commit()
            flash("Appointment booked successfully!", "success")
        except mysql.connector.Error as err:
            conn.rollback()
            flash(f"Error: {err}", "danger")

        return redirect('/appointments')  

    cursor.close() 

    return render_template('book_appointment.html', patients=patients, doctors=doctors)


@app.route('/appointments')
def view_appointments():
    cursor.execute("SELECT * FROM Appointments")
    appointments = cursor.fetchall()
    return render_template('appointments.html', appointments=appointments)


@app.route('/generate_bills', methods=['GET', 'POST'])
def generate_bills():
    if request.method == 'POST':
        patient_id = request.form['patient_id']
        amount = request.form['amount']

        cursor.callproc("GenerateBill", (patient_id, amount))
        conn.commit()

        flash("Bill generated successfully!", "success")
        return redirect('/bills')

    cursor.execute("SELECT patient_id, name FROM Patients")
    patients = cursor.fetchall()
    
    return render_template('generate_bills.html', patients=patients)


@app.route('/bills')
def bills():
    cursor = conn.cursor()
    cursor.execute("SELECT bill_id, patient_id, amount, status FROM Billing")  
    bills_data = cursor.fetchall()
    cursor.close()

    return render_template('bills.html', bills=bills_data)  



@app.route('/pay_bill', methods=['POST'])
def pay_bill():
    bill_id = request.form['bill_id']  

    cursor = conn.cursor()
    cursor.execute("UPDATE billing SET status = 'Paid' WHERE bill_id = %s", (bill_id,))
    conn.commit()
    cursor.close()
    return redirect('/bills')  

if __name__ == '__main__':
    app.run(debug=True)
