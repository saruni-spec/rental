import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
//
//Add maintance updated to a requested maintenance
export async function POST(request: Request) {
  try {
    //get the request details
    const body = await request.json();
    const { request_id, assigned_to, scheduled_date, notes } = body;

    // Check if request exists
    const requestMade = await prisma.maintenancerequest.findFirst({
      where: { request_id },
    });

    if (!requestMade) {
      return NextResponse.json(
        { error: "requestMade does not exist" },
        { status: 400 }
      );
    }

    //Update the maintance request
    const repairDetails = await prisma.maintenancerequest.update({
      where: { request_id },
      data: {
        assigned_to,
        scheduled_date,
        notes,
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
