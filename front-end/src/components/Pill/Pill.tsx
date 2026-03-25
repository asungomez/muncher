import type { PillColor } from "./utils";

const colorClasses: Record<PillColor, string> = {
  green: "bg-green-500 text-white",
  blue: "bg-blue-500 text-white",
  yellow: "bg-yellow-400 text-black",
  orange: "bg-orange-500 text-white",
  red: "bg-red-500 text-white",
  amber: "bg-amber-800 text-white",
  pink: "bg-pink-500 text-white",
  lime: "bg-lime-500 text-black",
  sky: "bg-sky-500 text-white",
  rose: "bg-rose-500 text-white",
};

const getPillColorClass = (color: PillColor) => {
  return colorClasses[color];
};

interface PillProps {
  content: string;
  color?: PillColor;
}

const Pill: React.FC<PillProps> = ({ content, color = "gray" }) => {
  const colorClass = getPillColorClass(color as PillColor);
  return (
    <span
      className={`inline-block px-3 py-1 text-sm font-semibold mr-2 mb-2 border-2 border-black shadow-[2px_2px_0px_#000] ${colorClass}`}
    >
      {content}
    </span>
  );
};

export default Pill;
