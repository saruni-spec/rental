import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
//
//Request a maintanace for a damage
export async function POST(request: Request) {
  try {
    //get the maintance request details
    const body = await request.json();
    const {
      damage_id,
      unit_id,
      requested_by,

      priority,
      description,
    } = body;

    // Check if unit exists
    const unit = await prisma.unit.findFirst({
      where: { unit_id },
    });

    if (!unit) {
      return NextResponse.json(
        { error: "unit does not exist" },
        { status: 400 }
      );
    }
    // Check if the damage exists
    const existingDamage = await prisma.damage.findFirst({
      where: {
        damage_id,
      },
    });

    if (!existingDamage) {
      return NextResponse.json(
        { error: "damage does not exist" },
        { status: 400 }
      );
    }
    //Add the maintance
    const maintanceRequest = await prisma.maintenancerequest.create({
      data: {
        damage_id,
        unit_id,
        requested_by,
        priority,
        description,
      },
    });

    return NextResponse.json(maintanceRequest, { status: 201 });
  } catch (error) {
    console.error("Error adding maintance:", error);
    return NextResponse.json(
      { error: "Error adding maintance" },
      { status: 500 }
    );
  }
}
