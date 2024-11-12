import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import bcrypt from "bcrypt";
//
//Create a new user
export async function POST(request: Request) {
  try {
    //get thw data for a user from the body
    const body = await request.json();
    const { email, password, first_name, last_name, phone } = body;

    // Check if user already exists
    const existingUser = await prisma.users.findFirst({
      where: {
        OR: [{ email }, { phone }],
      },
    });
    //
    //return an error
    if (existingUser) {
      return NextResponse.json(
        { error: "User with this email or phone number already exists" },
        { status: 400 }
      );
    }

    // Hash password,salt rounds=20,
    const hashedPassword = bcrypt.hash(password, 20);

    // Create user
    const user = await prisma.users.create({
      data: {
        first_name,
        last_name,
        email,
        phone,
        password_hash: await hashedPassword,
      },
    });

    // Remove password from response
    // Omit password_hash in the type
    const userData: Omit<typeof user, "password_hash"> = user;

    return NextResponse.json(userData, { status: 201 });
  } catch (error) {
    console.error("Error registering user:", error);
    return NextResponse.json(
      { error: "Error registering user" },
      { status: 500 }
    );
  }
}
