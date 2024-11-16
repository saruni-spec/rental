import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
//
//Create a new amenity
export async function POST(request: Request) {
  try {
    //get the amenity details from the body
    const body = await request.json();
    const { name, description } = body;

    // Check if the amenity already exists
    const existingAmenity = await prisma.amenity.findFirst({
      where: {
        AND: [{ name }, { description }],
      },
    });

    if (existingAmenity) {
      return NextResponse.json(
        { error: "amenity already registered" },
        { status: 400 }
      );
    }
    // Create amenity
    const amenity = await prisma.amenity.create({
      data: {
        name,
        description,
      },
    });

    return NextResponse.json(amenity, { status: 201 });
  } catch (error) {
    console.error("Error registering amenity:", error);
    return NextResponse.json(
      { error: "Error registering amenity" },
      { status: 500 }
    );
  }
}
