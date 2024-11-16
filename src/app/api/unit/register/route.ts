import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
//
//Create a new unit
export async function POST(request: Request) {
  try {
    //get the unit details from the body
    const body = await request.json();
    const {
      building_id,
      unit_number,
      floor_number,
      unit_type,
      square_footage,
      monthly_rent,
    } = body;

    // Check if the unit already exists
    //use building number and unit number as identifiers
    const existingBuilding = await prisma.unit.findFirst({
      where: {
        AND: [{ building_id }, { unit_number }],
      },
    });

    if (existingBuilding) {
      return NextResponse.json(
        { error: "unit already registered" },
        { status: 400 }
      );
    }
    // Create unit
    const unit = await prisma.unit.create({
      data: {
        building_id,
        unit_number,
        floor_number,
        unit_type,
        square_footage,
        monthly_rent,
      },
    });

    return NextResponse.json(unit, { status: 201 });
  } catch (error) {
    console.error("Error registering unit:", error);
    return NextResponse.json(
      { error: "Error registering unit" },
      { status: 500 }
    );
  }
}
