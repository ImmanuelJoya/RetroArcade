import { Link, Route, Routes } from "react-router-dom";  
import "./index.css"; 
import Home from "./pages/Home";
import Play from "./pages/Play";

export default function App() {
  return (
    <div className="min-h-screen bg-zinc-950 text-zinc-100">
      <header className="mx-auto max-w-5xl p-4 flex items-center justify-between">
        <Link to="/" className="text-xl font-bold">Retro Web Arcade</Link>
      </header>
      <main className="mx-auto max-w-5xl p-4">
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/play/:game" element={<Play />} />
        </Routes>
      </main>
    </div>
  );
}
