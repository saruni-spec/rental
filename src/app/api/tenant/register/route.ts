import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
//
//Create a new tenant
export async function POST(request: Request) {
  try {
    //get the tenant details from the body
    const body = await request.json();
    const { user_id, emergency_contact_name, emergency_contact_phone } = body;

    // Check if tenant already exists
    const existingTenant = await prisma.tenant.findFirst({
      where: {
        user_id,
      },
    });

    if (existingTenant) {
      return NextResponse.json(
        { error: "tenant with this id or tax id already exists" },
        { status: 400 }
      );
    }
    // Create tenant
    const tenant = await prisma.tenant.create({
      data: {
        user_id,
        emergency_contact_name,
        emergency_contact_phone,
      },
    });

    return NextResponse.json(tenant, { status: 201 });
  } catch (error) {
    console.error("Error registering tenant:", error);
    return NextResponse.json(
      { error: "Error registering tenant" },
      { status: 500 }
    );
  }
}
