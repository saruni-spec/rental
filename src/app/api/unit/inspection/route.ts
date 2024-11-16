import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
//
//Add an inpection to a unit
export async function POST(request: Request) {
  try {
    //get unit details and amenity details
    const body = await request.json();
    const { unit_id, inspector_id, inspection_date, inspection_type, notes } =
      body;

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
    //Add the amenity to the unit
    const inpection = await prisma.unitinspection.create({
      data: {
        unit_id,
        inspector_id,
        inspection_date,
        inspection_type,
        notes,
      },
    });

    return NextResponse.json(inpection, { status: 201 });
  } catch (error) {
    console.error("Error adding inpection:", error);
    return NextResponse.json(
      { error: "Error adding inpection" },
      { status: 500 }
    );
  }
}
