import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
//
//Create a billing
export async function POST(request: Request) {
  try {
    //get the billing details
    const body = await request.json();
    const { monthly_billing_id, amount, paid_for } = body;

    //Create the initial billing
    const billing = await prisma.billing.create({
      data: {
        monthly_billing_id,
        amount,
        paid_for,
      },
    });

    return NextResponse.json(billing, { status: 201 });
  } catch (error) {
    console.error("Error adding billing:", error);
    return NextResponse.json(
      { error: "Error adding billing" },
      { status: 500 }
    );
  }
}
