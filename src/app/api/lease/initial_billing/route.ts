import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
//
//Create the initial billing for a lease
export async function POST(request: Request) {
  try {
    //get the details for the initial billing
    const body = await request.json();
    const {
      lease_id,
      start_date,
      end_date,
      full_month_amount,
      prorated_amount,
      days_occupied,
    } = body;

    // Check if the lease exists
    const lease = await prisma.lease.findFirst({
      where: { lease_id },
    });

    if (!lease) {
      return NextResponse.json(
        { error: "lease does not exist" },
        { status: 400 }
      );
    }
    //Create the initial billing
    const initial_billing = await prisma.leaseinitialbilling.create({
      data: {
        lease_id,
        start_date,
        end_date,
        full_month_amount,
        prorated_amount,
        days_occupied,
      },
    });

    return NextResponse.json(initial_billing, { status: 201 });
  } catch (error) {
    console.error("Error adding initial billing:", error);
    return NextResponse.json(
      { error: "Error adding initial billing" },
      { status: 500 }
    );
  }
}
