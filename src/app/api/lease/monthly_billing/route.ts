import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
//
//Create the monthly billing for a lease
export async function POST(request: Request) {
  try {
    //get the details for the monthly billing
    const body = await request.json();
    const { lease_id, billing_month, amount, due_date } = body;

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
    //Create the monthly billing
    const initial_billing = await prisma.monthlybilling.create({
      data: {
        lease_id,
        billing_month,
        amount,
        due_date,
      },
    });

    return NextResponse.json(initial_billing, { status: 201 });
  } catch (error) {
    console.error("Error adding monthly billing:", error);
    return NextResponse.json(
      { error: "Error adding monthly billing" },
      { status: 500 }
    );
  }
}
