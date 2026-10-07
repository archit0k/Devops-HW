import React, { useEffect, useState } from 'react';
import { createRoot } from 'react-dom/client';
import './style.css';

const today = new Date().toLocaleDateString('en-CA');
const blank = { student_name: 'Archit Kulkarni', roll_no: '24BCS10194', room: 'Library A',
  booking_date: today, start_hour: 10, attendees: 2 };

async function api(path, options) {
  const response = await fetch(`/api${path}`, options);
  if (!response.ok) {
    const body = await response.json().catch(() => ({}));
    const message = typeof body.detail === 'string' ? body.detail : 'Check the booking details and try again.';
    throw new Error(message);
  }
  return response.status === 204 ? null : response.json();
}

function App() {
  const [bookings, setBookings] = useState([]);
  const [rooms, setRooms] = useState([]);
  const [form, setForm] = useState(blank);
  const [editing, setEditing] = useState(null);
  const [message, setMessage] = useState('');
  const [error, setError] = useState('');
  const [busy, setBusy] = useState(false);
  const [loading, setLoading] = useState(true);

  async function refresh() {
    const [nextBookings, nextRooms] = await Promise.all([api('/bookings'), api('/rooms')]);
    setBookings(nextBookings); setRooms(nextRooms);
  }
  useEffect(() => { refresh().catch(e => setError(e.message)).finally(() => setLoading(false)); }, []);

  function change(event) {
    const { name, value } = event.target;
    setForm(previous => ({ ...previous, [name]: ['attendees', 'start_hour'].includes(name) ? Number(value) : value }));
  }

  async function save(event) {
    event.preventDefault(); setBusy(true); setError(''); setMessage('');
    try {
      await api(editing ? `/bookings/${editing}` : '/bookings', {
        method: editing ? 'PUT' : 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(form),
      });
      await refresh(); setMessage(editing ? 'Booking updated.' : 'Room booked. You are all set.');
      setEditing(null); setForm(blank);
    } catch (e) { setError(e.message); } finally { setBusy(false); }
  }

  async function remove(booking) {
    if (!window.confirm(`Cancel ${booking.room} at ${booking.start_hour}:00?`)) return;
    setBusy(true); setError('');
    try { await api(`/bookings/${booking.id}`, { method: 'DELETE' }); await refresh(); setMessage('Booking cancelled.'); }
    catch (e) { setError(e.message); } finally { setBusy(false); }
  }

  function edit(booking) {
    const { id, ...fields } = booking;
    setForm(fields); setEditing(id); setMessage(''); setError('');
    document.getElementById('student_name').focus();
  }

  return <>
    <header><a className="brand" href="/">Study<span>Slot</span><small>CAMPUS ROOMS</small></a>
      <div className="owner">Archit Kulkarni <span>24BCS10194 · Section A</span></div></header>
    <main>
      <section className="intro"><p className="eyebrow">A LITTLE SPACE TO FOCUS</p>
        <h1>Find your room.<br /><em>Get some work done.</em></h1>
        <p>Book a one-hour slot for solo study or your next group session. No overlapping bookings, no last-minute room hunt.</p>
      </section>
      <section className="layout">
        <div className="card booking-form"><div className="card-heading"><h2>{editing ? 'Edit your booking' : 'Reserve a slot'}</h2><span>01</span></div>
          <form onSubmit={save}>
            <label htmlFor="student_name">Student name</label><input id="student_name" name="student_name" value={form.student_name} onChange={change} required minLength={2} maxLength={80} />
            <label htmlFor="roll_no">Roll number</label><input id="roll_no" name="roll_no" value={form.roll_no} onChange={change} required pattern="[A-Za-z0-9]{5,20}" />
            <label htmlFor="room">Room</label><select id="room" name="room" value={form.room} onChange={change}>
              {(rooms.length ? rooms : [{ name: 'Library A', capacity: 4 }, { name: 'Library B', capacity: 4 }, { name: 'Group Room', capacity: 6 }]).map(room => <option key={room.name}>{room.name}</option>)}
            </select>
            <div className="form-row"><div><label htmlFor="booking_date">Date</label><input id="booking_date" type="date" name="booking_date" value={form.booking_date} onChange={change} required /></div>
              <div><label htmlFor="start_hour">Start time</label><select id="start_hour" name="start_hour" value={form.start_hour} onChange={change}>
                {Array.from({ length: 13 }, (_, i) => i + 8).map(hour => <option key={hour} value={hour}>{String(hour).padStart(2, '0')}:00</option>)}
              </select></div></div>
            <label htmlFor="attendees">People</label><input id="attendees" type="number" name="attendees" min="1" max={rooms.find(room => room.name === form.room)?.capacity || 4} value={form.attendees} onChange={change} required />
            <p className="hint">Library rooms: up to 4 people. Group Room: up to 6.</p>
            <button className="primary" disabled={busy}>{busy ? 'Saving…' : editing ? 'Save changes' : 'Book this slot →'}</button>
            {editing && <button className="plain" type="button" onClick={() => { setEditing(null); setForm(blank); }}>Discard changes</button>}
          </form>
          {error && <p className="notice error" role="alert">{error}</p>}
          {message && <p className="notice success" role="status">{message}</p>}
        </div>
        <div className="schedule"><div className="card-heading"><h2>The room list</h2><span>{bookings.length} BOOKED</span></div>
          <p className="schedule-note">All reservations · one hour per slot</p>
          {loading ? <div className="empty">Loading bookings…</div> : bookings.length === 0 ? <div className="empty"><div className="empty-icon">↗</div><h3>Some quiet space is waiting.</h3><p>No bookings yet. Pick a room and make the first one.</p></div> :
            <div className="booking-list">{bookings.map(booking => <article className="reservation" key={booking.id}>
              <div className="time-block"><strong>{String(booking.start_hour).padStart(2, '0')}:00</strong><span>{booking.booking_date}</span></div>
              <div className="reservation-info"><h3>{booking.room}</h3><p>{booking.student_name} · {booking.attendees} {booking.attendees === 1 ? 'person' : 'people'}</p><small>{booking.roll_no}</small></div>
              <div className="actions"><button disabled={busy} onClick={() => edit(booking)}>Edit</button><button disabled={busy} onClick={() => remove(booking)}>Cancel</button></div>
            </article>)}</div>}
          <aside className="rule"><strong>A small reminder</strong><p>Keep the room tidy, finish within your slot, and cancel if your plans change.</p></aside>
        </div>
      </section>
    </main>
    <footer>StudySlot · DevOps course project <span>Local classroom demo — not a real campus booking service.</span></footer>
  </>;
}

createRoot(document.getElementById('root')).render(<App />);
