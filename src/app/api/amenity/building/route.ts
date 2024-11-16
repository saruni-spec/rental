import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
//
//Add an amenity to a building
export async function POST(request: Request) {
  try {
    //get building details and amenity details
    const body = await request.json();
    const { building_id, amenity_id } = body;

    // Check if building exists
    const building = await prisma.building.findFirst({
      where: { building_id },
    });

    if (!building) {
      return NextResponse.json(
        { error: "Building does not exist" },
        { status: 400 }
      );
    }
    // Check if the amenity exists
    const existingAmenity = await prisma.amenity.findFirst({
      where: {
        amenity_id,
      },
    });
    if (!existingAmenity) {
      return NextResponse.json(
        { error: "Amenity does not exist" },
        { status: 400 }
      );
    }
    //Add the amenity to the building
    const buildingAmenity = await prisma.buildingamenity.create({
      data: {
        building_id,
        amenity_id,
      },
    });

    return NextResponse.json(buildingAmenity, { status: 201 });
  } catch (error) {
    console.error("Error adding amenity to building:", error);
    return NextResponse.json(
      { error: "Error adding amenity to building" },
      { status: 500 }
    );
  }
}
