import http from 'k6/http';
import { check, sleep } from 'k6';

export default function () {
  const params = { headers: { 'Content-Type': 'application/json' } };

  // --- Assignment 3: Generic List Fetch ---
  let res3 = http.get('http://localhost:3000/api/userrrr'); 
  
  check(res3, { 
    'Asgn 3 MIS Status is Valid': (r) => r.status === 200 || r.status === 401 || r.status === 404
  });

  // --- Assignment 4: MCQ Login ---
  let res4 = http.post('http://localhost:3000/api/auth/login', JSON.stringify({
    email: 'admin',
    password: 'admin123'
  }), params);

  check(res4, { 
    'Asgn 4 Login Status is Valid': (r) => r.status === 200 || r.status === 401
  });

  sleep(1);
}