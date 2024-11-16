import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
//
//Report a damage to a unit
export async function POST(request: Request) {
  try {
    //get damage details from the body
    const body = await request.json();
    const {
      unit_id,
      inspection_id,
      tenant_id,
      reported_date,
      discovered_during,
      description,
      notes,
      file_path,
      uploaded_by,
    } = body;

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
    // Check if tenant already exists
    const existingTenant = await prisma.tenant.findFirst({
      where: {
        tenant_id,
      },
    });

    if (!existingTenant) {
      return NextResponse.json(
        { error: "tenant does not exist" },
        { status: 400 }
      );
    }
    //Add the damage
    const damage = await prisma.damage.create({
      data: {
        unit_id,
        inspection_id,
        tenant_id,
        reported_date,
        discovered_during,
        description,
        notes,
        file_path,
        uploaded_by,
      },
    });

    return NextResponse.json(damage, { status: 201 });
  } catch (error) {
    console.error("Error adding damage:", error);
    return NextResponse.json({ error: "Error adding damage" }, { status: 500 });
  }
}
