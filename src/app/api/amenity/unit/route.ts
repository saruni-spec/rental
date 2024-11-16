import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
//
//Add an amenity to a unit
export async function POST(request: Request) {
  try {
    //get unit details and amenity details
    const body = await request.json();
    const { unit_id, amenity_id } = body;

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
    //Add the amenity to the unit
    const unitamenity = await prisma.unitamenity.create({
      data: {
        unit_id,
        amenity_id,
      },
    });

    return NextResponse.json(unitamenity, { status: 201 });
  } catch (error) {
    console.error("Error adding amenity to unit:", error);
    return NextResponse.json(
      { error: "Error adding amenity to unit" },
      { status: 500 }
    );
  }
}
