import { Link } from "react-router-dom";

const games = [
    { id: "doom1", title: "DOOM 1 (Freedoom Phase 1)", desc: "Classic campaign using free assets." },
    { id: "doom2", title: "DOOM 2 (Freedoom Phase 2)", desc: "New monsters; also fully free." },
];

export default function Home() {
    return (
        <section className="grid gap-6 sm:grid-cols-2">
            {games.map(g => (
                <Link
                    key={g.id}
                    to={`/play/${g.id}`}
                    className="rounded-2xl border border-zinc-800 p-6 hover:border-zinc-600 hover:bg-zinc-900/40 transition"
                >
                    <h2 className="text-lg font-semibold">{g.title}</h2>
                    <p className="mt-2 text-sm text-zinc-400">{g.desc}</p>
                    <p className="mt-4 text-xs text-zinc-500">Click to play →</p>
                </Link>
            ))}
        </section>
    );
}
