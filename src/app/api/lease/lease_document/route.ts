import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
//
//Create the lease document for a lease
export async function POST(request: Request) {
  try {
    //get the details for the lease document
    const body = await request.json();
    const { lease_id, document_type, file_path, uploaded_by } = body;

    // Check if the lease exists
    const lease = await prisma.lease.findFirst({
      where: { lease_id },
    });

    if (!lease) {
      return NextResponse.json(
        { error: "lease does not exist" },
        { status: 400 }
      );
    }
    //Create the lease document
    const initial_billing = await prisma.leasedocument.create({
      data: {
        lease_id,
        document_type,
        file_path,
        uploaded_by,
      },
    });

    return NextResponse.json(initial_billing, { status: 201 });
  } catch (error) {
    console.error("Error adding lease document:", error);
    return NextResponse.json(
      { error: "Error adding lease document" },
      { status: 500 }
    );
  }
}
