import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
//
//Add a payment
export async function POST(request: Request) {
  try {
    //get the payment details
    const body = await request.json();
    const {
      monthly_billing_id,
      amount,
      payment_date,
      payment_method,
      transaction_reference,
      notes,
    } = body;

    //Create the monthly billing
    const payment = await prisma.payment.create({
      data: {
        monthly_billing_id,
        amount,
        payment_date,
        payment_method,
        transaction_reference,
        notes,
      },
    });

    return NextResponse.json(payment, { status: 201 });
  } catch (error) {
    console.error("Error adding monthly billing:", error);
    return NextResponse.json(
      { error: "Error adding monthly billing" },
      { status: 500 }
    );
  }
}
