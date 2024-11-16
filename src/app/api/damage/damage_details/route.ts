import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
//
//Add damage details eg repairs
export async function POST(request: Request) {
  try {
    //get damage details from the body
    const body = await request.json();
    const {
      damage_id,
      estimated_repair_cost,
      actual_repair_cost,
      severity,
      repaired_date,
      is_tenant_liable,
    } = body;

    // Check if the damage exists
    const damage = await prisma.damage.findFirst({
      where: { damage_id },
    });

    if (!damage) {
      return NextResponse.json(
        { error: "damage does not exist" },
        { status: 400 }
      );
    }
    //Add the damageDetails
    const damageDetails = await prisma.damageDetails.create({
      data: {
        damage_id,
        estimated_repair_cost,
        actual_repair_cost,
        severity,
        repaired_date,
        is_tenant_liable,
      },
    });

    return NextResponse.json(damageDetails, { status: 201 });
  } catch (error) {
    console.error("Error adding damageDetails:", error);
    return NextResponse.json(
      { error: "Error adding damageDetails" },
      { status: 500 }
    );
  }
}
