import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
//
//Create a lease
export async function POST(request: Request) {
  try {
    //gwt the unit an tenant
    const body = await request.json();
    const {
      unit_id,
      tenant_id,
      start_date,
      initial_term_months,
      monthly_rent,
      security_deposit,
    } = body;

    // Check if tenant exists
    const tenant = await prisma.tenant.findFirst({
      where: { tenant_id },
    });

    if (!tenant) {
      return NextResponse.json(
        { error: "tenant does not exist" },
        { status: 400 }
      );
    }
    // Check if the unit exists
    const existingUnit = await prisma.unit.findFirst({
      where: {
        unit_id,
      },
    });
    if (existingUnit) {
      return NextResponse.json(
        { error: "unit does not exist" },
        { status: 400 }
      );
    }
    //Create the lease document
    const lease = await prisma.lease.create({
      data: {
        unit_id,
        tenant_id,
        start_date,
        initial_term_months,
        monthly_rent,
        security_deposit,
      },
    });

    return NextResponse.json(lease, { status: 201 });
  } catch (error) {
    console.error("Error creating lease:", error);
    return NextResponse.json(
      { error: "Error creating lease" },
      { status: 500 }
    );
  }
}
