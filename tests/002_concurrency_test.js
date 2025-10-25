/*
  Concurrency test: spawn N parallel reserve_spot calls against the same small-capacity group
  Usage: configure DB connection via environment variables (PGHOST, PGUSER, PGPASSWORD, PGDATABASE)
*/

const { Pool } = require('pg');

const pool = new Pool(); // uses environment variables

const GROUP_ID = '22222222-2222-2222-2222-222222222222';
const TEST_EMAIL_PREFIX = 'concurrent';
const PARALLEL = 6; // attempt more than capacity

async function setup() {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    await client.query('DELETE FROM registrations WHERE group_id = $1', [GROUP_ID]);
    await client.query('DELETE FROM course_groups WHERE group_id = $1', [GROUP_ID]);
    await client.query("INSERT INTO course_groups (group_id, name, max_capacity, registered_count, reserved_count, is_active) VALUES ($1,'CONC TEST',2,0,0,true) ON CONFLICT DO NOTHING", [GROUP_ID]);
    await client.query('COMMIT');
  } finally {
    client.release();
  }
}

async function runReserve(i) {
  const client = await pool.connect();
  try {
    const email = `${TEST_EMAIL_PREFIX}${i}@example.com`;
    const res = await client.query('SELECT reserve_spot($1,$2,$3,$4) as registration_id', [GROUP_ID, email, `User ${i}`, `0555${1000 + i}`]);
    return { ok: true, reg: res.rows[0].registration_id };
  } catch (err) {
    return { ok: false, err: err.message };
  } finally {
    client.release();
  }
}

async function main() {
  await setup();

  const promises = [];
  for (let i = 0; i < PARALLEL; i++) promises.push(runReserve(i));

  const results = await Promise.all(promises);

  console.log('Results:');
  results.forEach((r, idx) => {
    console.log(idx, r.ok ? `OK ${r.reg}` : `ERR ${r.err}`);
  });

  // Check final counts
  const client = await pool.connect();
  try {
    const counts = await client.query('SELECT registered_count, reserved_count, max_capacity FROM course_groups WHERE group_id = $1', [GROUP_ID]);
    console.log('Final counts:', counts.rows[0]);
  } finally {
    client.release();
  }

  await pool.end();
}

main().catch(err => { console.error(err); process.exit(1); });
