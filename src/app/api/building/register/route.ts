import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
//
//Create a new building
export async function POST(request: Request) {
  try {
    //get the building details from the body
    const body = await request.json();
    const {
      owner_id,
      name,
      address_line1,
      address_line2,
      city,
      state,
      postal_code,
      country,
      construction_year,
      total_units,
    } = body;

    // Check if the building already exists
    const existingBuilding = await prisma.building.findFirst({
      where: {
        AND: [{ address_line1 }, { address_line2 }],
      },
    });

    if (existingBuilding) {
      return NextResponse.json(
        { error: "Building already registered" },
        { status: 400 }
      );
    }
    // Create building
    const building = await prisma.building.create({
      data: {
        owner_id,
        name,
        address_line1,
        address_line2,
        city,
        state,
        postal_code,
        country,
        construction_year,
        total_units,
      },
    });

    return NextResponse.json(building, { status: 201 });
  } catch (error) {
    console.error("Error registering building:", error);
    return NextResponse.json(
      { error: "Error registering building" },
      { status: 500 }
    );
  }
}
