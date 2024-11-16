import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
//
//adding repair details to a damage in a unit
export async function POST(request: Request) {
  try {
    //get the repair details
    const body = await request.json();
    const { damage_id, actual_repair_cost, repaired_date } = body;

    // Check if damage exists
    const damage = await prisma.damage.findFirst({
      where: { damage_id },
    });

    if (!damage) {
      return NextResponse.json(
        { error: "damage does not exist" },
        { status: 400 }
      );
    }

    //Add the repair details
    const repairDetails = await prisma.damageDetails.update({
      where: { damage_id },
      data: {
        actual_repair_cost,
        repaired_date,
      },
    });

    return NextResponse.json(repairDetails, { status: 201 });
  } catch (error) {
    console.error("Error adding repair details:", error);
    return NextResponse.json(
      { error: "Error adding repair details" },
      { status: 500 }
    );
  }
}
