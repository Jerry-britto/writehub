import { Button } from "@/components/ui/button";
import Image from "next/image";

export default function Home() {
  return (
    <div>
      <h1 className="bg-red-400 text-center">Hello world</h1>
      <Button className="bg-amber-300">Click me</Button>
    </div>
  );
}
