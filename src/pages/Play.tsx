import { useEffect, useRef } from "react";
import { Link, useParams } from "react-router-dom";

const mapping: Record<string, string> = {
    doom1: "doom1.wad",
    doom2: "doom2.wad",
};

declare global {
    interface Window { Module?: any; }
}

export default function Play() {
    const { game } = useParams();
    const iwad = mapping[game ?? ""] ?? "doom1.wad";
    const canvasRef = useRef<HTMLCanvasElement | null>(null);

    useEffect(() => {
        // Configure Module before loading doom.js
        window.Module = {
            arguments: ["-iwad", iwad],
            canvas: canvasRef.current!,
        };

        const s = document.createElement("script");
        s.src = "/engine/doom.js"; // doom.js will request /engine/doom.wasm and /engine/<wad>
        s.async = true;
        document.body.appendChild(s);

        return () => {
            s.remove();
            // eslint-disable-next-line @typescript-eslint/no-explicit-any
            (window as any).Module = undefined;
        };
    }, [iwad]);

    return (
        <div className="space-y-4">
            <div className="flex items-center justify-between">
                <Link to="/" className="text-sm text-zinc-400 hover:text-zinc-200">← Back</Link>
                <div className="text-sm text-zinc-500">IWAD: {iwad}</div>
            </div>
            <div className="border border-zinc-800 rounded-xl overflow-hidden">
                <canvas ref={canvasRef} id="doom-canvas" className="w-full h-[70vh] block bg-black" />
            </div>
        </div>
    );
}
