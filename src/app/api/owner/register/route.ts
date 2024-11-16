import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
//
//Create a new owner
export async function POST(request: Request) {
  try {
    //get the owner details from the body
    const body = await request.json();
    const { user_id, company_name, tax_id } = body;

    // Check if owner already exists
    const existingOwner = await prisma.owner.findFirst({
      where: {
        OR: [{ user_id }, { tax_id }],
      },
    });

    if (existingOwner) {
      return NextResponse.json(
        { error: "Owner with this id or tax id already exists" },
        { status: 400 }
      );
    }
    // Create owner
    const owner = await prisma.owner.create({
      data: {
        user_id,
        company_name,
        tax_id,
      },
    });

    return NextResponse.json(owner, { status: 201 });
  } catch (error) {
    console.error("Error registering owner:", error);
    return NextResponse.json(
      { error: "Error registering owner" },
      { status: 500 }
    );
  }
}
