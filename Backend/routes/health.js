// pages/api/health.js (for Pages Router)
// OR app/api/health/route.js (for App Router)

import { NextResponse } from 'next/server';

// For App Router (app/api/health/route.js)
export async function GET() {
  try {
    return NextResponse.json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      service: 'Quiz Generator API',
      version: '1.0.0'
    });
  } catch (error) {
    return NextResponse.json({
      status: 'error',
      message: error.message
    }, { status: 500 });
  }
}

// For Pages Router (pages/api/health.js)
export default function handler(req, res) {
  if (req.method === 'GET') {
    res.status(200).json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      service: 'Quiz Generator API',
      version: '1.0.0'
    });
  } else {
    res.status(405).json({ error: 'Method not allowed' });
  }
}